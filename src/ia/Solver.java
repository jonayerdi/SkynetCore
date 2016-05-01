package ia;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import configuration.Configuration;
import configuration.Logger;
import connections.Message;
import database.Incidencia;
import database.IncidenciaFacade;
import database.Recurso;
import database.RecursoFacade;

public abstract class Solver implements Comparator<Incidencia>, Serializable {

private static final long serialVersionUID = 1L;
	
	Logger log;
	MonoSemaphore lock;
	Thread solver;
	Recurso[] recursosId;
	Recurso[] recursos;
	Incidencia[] incidencias;
	Map<Integer,Incidencia> recursoIncidencia;
	
	IncidenciaFacade incidenciaFacade;
	RecursoFacade recursoFacade;
	
	public Solver(List<String> settings) {
		
		lock = new MonoSemaphore();
		
		solver = new Thread() {
			public void run() {
				solverTask();
			}
		};
		solver.start();
		
	}
	
	public void init() {
		log = Configuration.getCurrent().getLogger();
		incidenciaFacade = new IncidenciaFacade();
		recursoFacade = new RecursoFacade();
		recursoIncidencia = Configuration.getCurrent().getRecursoIncidencia();
	}
	
	public synchronized void scheduleSolution(Recurso[] recursos) {
		this.recursosId = recursos;
		lock.release();
		log.log(getClass()+" scheduled", Logger.DEBUG);
	}
	
	private synchronized void setRecursos() {
		recursos = new Recurso[recursosId.length];
		for(int i = 0 ; i < recursos.length ; i++) {
			recursos[i] = recursoFacade.getRecurso(recursosId[i].id);
			recursos[i].setConnection(recursosId[i].getConnection());
		}
	}
	
	public void solverTask() {
		while(true) {
			lock.acquire();
			log.log(getClass()+" started");
			setRecursos();
			incidencias = incidenciaFacade.getIncidenciasAbiertas();
			assign(solve());
		}
	}
	
	public abstract Solution[] solve();
	
	public void sortIncidencias() {
		for(int i = 0 ; i < incidencias.length ; i++) {
			incidencias[i].getPrioridad();
		}
		List<Incidencia> incList = Arrays.asList(incidencias);
		incList.sort(this);
		incidencias = incList.toArray(new Incidencia[0]);
	}
	
	public void assign(Solution[] solution) {
		log.log(getClass()+" solved, sending messages");
		//Asignar las rutas para resolver incidencias
		for(int i = 0 ; i < solution.length ; i++) {
			try {
				log.log("Sending incidencia "+solution[i].incidencia.id+" to recurso "+solution[i].recurso.id+", route takes "+solution[i].ruta.getTimeString(), Logger.DEBUG);
				solution[i].recurso.getConnection().writeMessage(new Message(solution[i].recurso.id,"ROUTE",solution[i].ruta.toString()));
				recursoIncidencia.put(solution[i].recurso.id, solution[i].incidencia);
				if(solution[i].recurso.estado==Recurso.ESTADO_EN_RUTA) solution[i].recurso.estado = -9;
			} catch(Exception e){
				log.log("Error sending incidencia "+(solution[i]==null ? "NULL":solution[i].incidencia),Logger.ERROR);
			}
		}
		//Avisar a los que ya no tienen que hacer nada
		log.log("Sending void routes to previously busy resources");
		for(int i = 0 ; i < recursos.length ; i++) {
			try {
				if(recursos[i].estado==Recurso.ESTADO_EN_RUTA) {
					log.log("Sending void route to recurso "+recursos[i].id,Logger.DEBUG);
					recursos[i].getConnection().writeMessage(new Message(recursos[i].id,"ROUTE","{}"));
					recursoIncidencia.remove(recursos[i].id);
				}
				else if(recursos[i].estado==-9)
					recursos[i].estado = Recurso.ESTADO_EN_RUTA;
			} catch(Exception e){
				log.log("Error sending void route to recurso "+recursos[i].id,Logger.ERROR);
			}
		}
		log.log(getClass()+" finished");
	}

	public int compare(Incidencia incidencia1, Incidencia incidencia2) {
		return incidencia1.prioridad-incidencia2.prioridad;
	}
	
}

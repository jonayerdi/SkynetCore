package ia;

import java.util.List;

import configuration.Logger;
import database.Recurso;

public class RandomSolver extends Solver {
	
	Route route;
	Recurso recurso;
	int recursoId;
	Solution[] sol;

	public RandomSolver(List<String> settings) {
		super(settings);
	}

	private static final long serialVersionUID = 1L;
	
	public Solution[] solve() {
		sol = new Solution[incidencias.length];
		log.log(getClass()+" started -> "+incidencias.length+" incidences / "+recursos.length+" resources", Logger.SOLVER);
		if(incidencias.length>0 && recursos.length>0) {
			for(int i = 0 ; i < sol.length ; i++) {
				resolverIncidencia(i);
			}
		}
		log.log(getClass()+" solved", Logger.SOLVER);
		return sol;
	}
	
	public void resolverIncidencia(int num) {
		try {
			recursoId = 0;
			log.log("Solving incidence ID = "+incidencias[num].id+" TYPE = "+incidencias[num].tipo, Logger.SOLVER);
			while(recursos[recursoId].tipo!=incidencias[num].tipo || recursos[recursoId].estado!=Recurso.ESTADO_LIBRE) recursoId++;
			recurso = recursos[recursoId];
			route = new Route(recurso,incidencias[num]);
			sol[num] = new Solution(incidencias[num],recurso,route);
			recurso.estado = Recurso.ESTADO_EN_RUTA;
			log.log("Resource ID = "+recurso.id+" assigned to incidence ID = "+incidencias[num].id+", route takes "+route.getTimeString(), Logger.SOLVER);
		} catch(Exception e){}
	}
	
}

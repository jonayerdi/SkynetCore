package ia;

import java.util.List;

import configuration.Logger;
import database.Recurso;

public class AStarSolver extends Solver {
	
	private static final long serialVersionUID = 1L;
	
	Route route, routeTemp;
	Recurso recurso;
	int recursoId;
	Solution[] solutions;
	
	public AStarSolver(List<String> settings) {
		super(settings);
	}

	public Solution[] solve() {
		solutions = new Solution[incidencias.length];
		log.log(getClass()+" started -> "+incidencias.length+" incidences / "+recursos.length+" resources", Logger.SOLVER);
		if(incidencias.length>0 && recursos.length>0) {
			log.log("Sorting incidences by priority", Logger.SOLVER);
			sortIncidencias();
			log.log("Sorting ended", Logger.SOLVER);
			for(int i = 0 ; i < incidencias.length ; i++) {
				try {
					resolverIncidencia(i);
					if(route!=null) {
						recurso = recursos[recursoId];
						solutions[i] = new Solution(incidencias[i],recurso,route);
						recurso.estado = Recurso.ESTADO_EN_RUTA;
						log.log("Resource ID = "+recurso.id+" assigned to incidence ID = "+incidencias[i].id+", route takes "+route.getTimeString(), Logger.SOLVER);
					}
				} catch(Exception e2){}
			}
		}
		log.log(getClass()+" solved", Logger.SOLVER);
		return solutions;
	}
	
	public void resolverIncidencia(int num) {
		recursoId = -1;
		route = null;
		log.log("Solving incidence ID = "+incidencias[num].id+" TYPE = "+incidencias[num].tipo, Logger.SOLVER);
		for(int j = 0;j < recursos.length;j++) {
			try {
				if(recursos[j].tipo==incidencias[num].tipo && recursos[j].estado<2) {
					routeTemp = new Route(recursos[j],incidencias[num]);
					if(route==null || route.getTime()>routeTemp.getTime()) {
						recursoId = recursos[j].id;
						route = routeTemp;
						log.log("Incidence ID = "+incidencias[num].id+" resource found ID = "+recursoId+" route takes "+route.getTimeString(), Logger.SOLVER);
					}
				}
			} catch(Exception e1){}
		}
	}
	
}

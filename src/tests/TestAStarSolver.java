package tests;

import static org.junit.Assert.fail;
import ia.AStarSolver;

import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import org.easymock.EasyMockSupport;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ui.MainWindow;
import configuration.Configuration;
import configuration.Logger;
import database.Recurso;

//Test para la clase AStarSolver, utilizando el Logger para la comprobacion
public class TestAStarSolver extends EasyMockSupport implements WindowListener {
	
	MainWindow window;
	Logger log;
	
	Recurso[] recursos;
	
	@Before
	public void setUp() {
		//Configuration
		try {
			Configuration.loadFromFile();
		} catch(Exception e) {
			fail("Error loading config file");
		}
		//AStarSolver
		Configuration.getCurrent().setSolver(new AStarSolver(null));
		//Logger MOCK
		log = strictMock(Logger.class);
		Configuration.getCurrent().setLogger(log);
		//Solver
		Configuration.getCurrent().getSolver().init();
	}
	
	@Before
	public void data() {
		Recurso r1 = new Recurso();
		Recurso r2 = new Recurso();
		Recurso r3 = new Recurso();
		r1.id = 1;
		r2.id = 2;
		r3.id = 7;
		recursos = new Recurso[] {r1,r2,r3};
	}
	
	@Test
	public void testSolver() {
		log.log("class ia.AStarSolver scheduled",0);
		log.log("class ia.AStarSolver started");
		log.log("class ia.AStarSolver started -> 1 incidences / 3 resources",5);
		log.log("Sorting incidences by priority",5);
		log.log("Sorting ended",5);
		log.log("Solving incidence ID = 87 TYPE = 1",5);
		log.log("Incidence ID = 87 resource found ID = 1 route takes 45 mins",5);
		log.log("Resource ID = 2 assigned to incidence ID = 87, route takes 45 mins", 5);
		log.log("class ia.AStarSolver solved",5);
		log.log("class ia.AStarSolver solved, sending messages");
		log.log("Sending incidencia 87 to recurso 2, route takes 45 mins", 0);
		log.log("Error sending incidencia 87#43.27895#-1.984636",3);
		log.log("Sending void routes to previously busy resources");
		log.log("Sending void route to recurso 2", 0);
		log.log("Error sending void route to recurso 2", 3);
		log.log("class ia.AStarSolver finished");
		replayAll();
		Configuration.getCurrent().getSolver().scheduleSolution(recursos);
		try {
			Thread.sleep(4000);
		} catch(Exception e) {}
		verifyAll();
	}
	
	@After
	public void cleanUp() {
		
	}
	
	//////////////////WindowListener//////////////////////
	public void windowActivated(WindowEvent arg0) {}
	public void windowClosed(WindowEvent arg0) {}
	public void windowClosing(WindowEvent arg0) {}
	public void windowDeactivated(WindowEvent arg0) {}
	public void windowDeiconified(WindowEvent arg0) {}
	public void windowIconified(WindowEvent arg0) {}
	public void windowOpened(WindowEvent arg0) {}
	
}

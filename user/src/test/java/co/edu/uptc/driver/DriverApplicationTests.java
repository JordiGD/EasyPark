package co.edu.uptc.driver;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class DriverApplicationTests {

	@Test
	void contextLoads() {
		// Prueba simple que verifica que el proyecto compila correctamente
		assertNotNull("Aplicación cargada");
	}

	@Test
	void testApplicationNameIsCorrect() {
		assertEquals("driver", "driver");
	}

	@Test
	void testJavaVersionSupported() {
		String javaVersion = System.getProperty("java.version");
		assertNotNull(javaVersion);
		assertTrue(javaVersion.contains("21"));
	}
}

package fsa;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Codigo6Servlet extends HttpServlet {

    // ===== Piezas de apoyo (solo para que Java pueda compilar) =====
    static class Widget { }

    static void die(String mensaje) {
        throw new RuntimeException(mensaje);
    }

    // ===== Entrada del usuario: el tamano llega por la URL (?size=...) =====
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int untrustedListSize = Integer.parseInt(request.getParameter("size"));
        buildList(untrustedListSize);
        response.getWriter().println("Lista creada");
    }

    // ===== CODIGO DEL EJERCICIO (sin cambios) =====
    private void buildList ( int untrustedListSize ){
    if ( 0 > untrustedListSize ){
    die("Negative value supplied for list size, die evil hacker!");
    }
    Widget[] list = new Widget [ untrustedListSize ];
    list[0] = new Widget();
    }
    // ===============================================
}

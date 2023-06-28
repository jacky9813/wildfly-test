package org.jboss.as.quickstarts.helloworld;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/redirect-http")
public class RedirectHttp extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hostname = req.getHeader("Host");
        String path = req.getRequestURI();
        resp.sendRedirect(String.format(
            "http://%s%s",
            hostname,
            path.replace("redirect-http", "HelloWorld")
        ));
    }
}

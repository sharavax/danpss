package com.danpss.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.html?error=session_required");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));
        if ("Student".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/student");
            return;
        }
        if ("Alumni".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/alumni");
            return;
        }
        if ("Placement Officer".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/index.html");
    }
}

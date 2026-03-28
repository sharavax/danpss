package com.danpss.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public final class AccessControlUtil {
    private AccessControlUtil() {
    }

    public static HttpSession requireRole(HttpServletRequest req, HttpServletResponse resp, String... allowedRoles) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.html?error=session_required");
            return null;
        }

        String currentRole = String.valueOf(session.getAttribute("userRole"));
        for (int i = 0; i < allowedRoles.length; i++) {
            if (allowedRoles[i].equalsIgnoreCase(currentRole)) {
                return session;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?error=access_denied");
        return null;
    }
}

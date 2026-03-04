package com.danpss.servlets;

import com.danpss.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PlacementReportServlet", urlPatterns = {"/reports/placement"})
public class PlacementReportServlet extends HttpServlet {

    private static final String SUMMARY_SQL =
            "SELECT COUNT(*) AS total_students, " +
            "SUM(CASE WHEN company IS NOT NULL AND company <> '' AND designation IS NOT NULL AND designation <> '' THEN 1 ELSE 0 END) AS placed_students " +
            "FROM students " +
            "WHERE (? = '' OR department = ?) " +
            "AND (? = '' OR graduation_year = ?) " +
            "AND (? = '' OR company LIKE CONCAT('%', ?, '%'))";

    private static final String DETAILS_SQL =
            "SELECT student_id, name, email, department, graduation_year, company, designation " +
            "FROM students " +
            "WHERE (? = '' OR name LIKE CONCAT('%', ?, '%')) " +
            "AND (? = '' OR department = ?) " +
            "AND (? = '' OR graduation_year = ?) " +
            "AND (? = '' OR company LIKE CONCAT('%', ?, '%')) " +
            "ORDER BY graduation_year DESC, name ASC";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = nv(req.getParameter("search"));
        String department = nv(req.getParameter("department"));
        String company = nv(req.getParameter("company"));
        int graduationYear = parseInt(req.getParameter("graduationYear"));

        int totalStudents = 0;
        int placedStudents = 0;
        double placementRate = 0.0;
        List<String[]> rows = new ArrayList<String[]>();

        try (Connection con = DBUtil.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(SUMMARY_SQL)) {
                ps.setString(1, department);
                ps.setString(2, department);
                ps.setString(3, graduationYear == 0 ? "" : String.valueOf(graduationYear));
                ps.setInt(4, graduationYear == 0 ? 0 : graduationYear);
                ps.setString(5, company);
                ps.setString(6, company);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalStudents = rs.getInt("total_students");
                        placedStudents = rs.getInt("placed_students");
                        if (totalStudents > 0) {
                            placementRate = (placedStudents * 100.0) / totalStudents;
                        }
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(DETAILS_SQL)) {
                ps.setString(1, search);
                ps.setString(2, search);
                ps.setString(3, department);
                ps.setString(4, department);
                ps.setString(5, graduationYear == 0 ? "" : String.valueOf(graduationYear));
                ps.setInt(6, graduationYear == 0 ? 0 : graduationYear);
                ps.setString(7, company);
                ps.setString(8, company);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        rows.add(new String[]{
                                String.valueOf(rs.getInt("student_id")),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("department"),
                                String.valueOf(rs.getInt("graduation_year")),
                                nv(rs.getString("company")),
                                nv(rs.getString("designation"))
                        });
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("search", search);
        req.setAttribute("department", department);
        req.setAttribute("company", company);
        req.setAttribute("graduationYear", graduationYear == 0 ? "" : String.valueOf(graduationYear));
        req.setAttribute("totalStudents", totalStudents);
        req.setAttribute("placedStudents", placedStudents);
        req.setAttribute("placementRate", String.format("%.2f", placementRate));
        req.setAttribute("rows", rows);

        req.getRequestDispatcher("/reports/placement-report.jsp").forward(req, resp);
    }

    private String nv(String value) {
        return value == null ? "" : value.trim();
    }

    private int parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? 0 : Integer.parseInt(value.trim());
        } catch (Exception e) {
            return 0;
        }
    }
}

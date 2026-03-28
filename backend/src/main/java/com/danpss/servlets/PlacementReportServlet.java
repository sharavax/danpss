package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.AccessControlUtil;

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
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (AccessControlUtil.requireRole(req, resp, "Placement Officer") == null) {
            return;
        }
        String search = normalize(req.getParameter("search"));
        String department = normalize(req.getParameter("department"));
        String company = normalize(req.getParameter("company"));
        String graduationYear = normalize(req.getParameter("graduationYear"));

        List<String[]> rows = new ArrayList<String[]>();
        List<String[]> departmentRows = new ArrayList<String[]>();
        List<String[]> companyRows = new ArrayList<String[]>();

        String detailsSql =
                "SELECT s.student_id, u.full_name, u.email, d.department_name, s.graduation_year, " +
                "COALESCE(c.company_name, '') AS company_name, COALESCE(des.designation_name, '') AS designation_name " +
                "FROM students s " +
                "JOIN users u ON u.user_id = s.user_id " +
                "JOIN departments d ON d.department_id = s.department_id " +
                "LEFT JOIN companies c ON c.company_id = s.current_company_id " +
                "LEFT JOIN designations des ON des.designation_id = s.designation_id " +
                "WHERE (? = '' OR u.full_name LIKE CONCAT('%', ?, '%')) " +
                "AND (? = '' OR d.department_name = ?) " +
                "AND (? = '' OR s.graduation_year = ?) " +
                "AND (? = '' OR c.company_name LIKE CONCAT('%', ?, '%')) " +
                "ORDER BY s.student_id DESC";

        try (Connection con = DBUtil.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(detailsSql)) {
                ps.setString(1, search);
                ps.setString(2, search);
                ps.setString(3, department);
                ps.setString(4, department);
                ps.setString(5, graduationYear);
                ps.setString(6, graduationYear);
                ps.setString(7, company);
                ps.setString(8, company);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        rows.add(new String[]{
                                String.valueOf(rs.getInt("student_id")),
                                rs.getString("full_name"),
                                rs.getString("email"),
                                rs.getString("department_name"),
                                rs.getString("graduation_year"),
                                rs.getString("company_name"),
                                rs.getString("designation_name")
                        });
                    }
                }
            }

            loadDepartmentBreakdown(con, departmentRows);
            loadCompanyRows(con, companyRows);

            int totalStudents = countAllStudents(con);
            int placedStudents = countPlacedStudents(con);
            double placementRate = totalStudents == 0 ? 0.0 : (placedStudents * 100.0) / totalStudents;

            req.setAttribute("search", search);
            req.setAttribute("department", department);
            req.setAttribute("company", company);
            req.setAttribute("graduationYear", graduationYear);
            req.setAttribute("rows", rows);
            req.setAttribute("resultCount", rows.size());
            req.setAttribute("totalStudents", totalStudents);
            req.setAttribute("placedStudents", placedStudents);
            req.setAttribute("placementRate", String.format("%.2f", placementRate));
            req.setAttribute("departmentRows", departmentRows);
            req.setAttribute("companyRows", companyRows);
            req.getRequestDispatcher("/reports/placement-report.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void loadDepartmentBreakdown(Connection con, List<String[]> rows) throws Exception {
        String sql =
                "SELECT d.department_name, COUNT(*) AS total_count, " +
                "SUM(CASE WHEN s.current_company_id IS NOT NULL THEN 1 ELSE 0 END) AS placed_count " +
                "FROM students s " +
                "JOIN departments d ON d.department_id = s.department_id " +
                "GROUP BY d.department_name ORDER BY d.department_name";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int total = rs.getInt("total_count");
                int placed = rs.getInt("placed_count");
                double rate = total == 0 ? 0.0 : (placed * 100.0) / total;
                rows.add(new String[]{
                        rs.getString("department_name"),
                        String.valueOf(total),
                        String.valueOf(placed),
                        String.format("%.2f", rate)
                });
            }
        }
    }

    private void loadCompanyRows(Connection con, List<String[]> rows) throws Exception {
        String sql =
                "SELECT c.company_name, COUNT(*) AS hires " +
                "FROM students s " +
                "JOIN companies c ON c.company_id = s.current_company_id " +
                "GROUP BY c.company_name ORDER BY hires DESC, c.company_name";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new String[]{rs.getString("company_name"), String.valueOf(rs.getInt("hires"))});
            }
        }
    }

    private int countAllStudents(Connection con) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM students");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private int countPlacedStudents(Connection con) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM students WHERE current_company_id IS NOT NULL");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}

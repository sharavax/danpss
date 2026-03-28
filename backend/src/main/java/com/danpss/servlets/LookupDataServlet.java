package com.danpss.servlets;

import com.danpss.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "LookupDataServlet", urlPatterns = {"/api/lookups"})
public class LookupDataServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        try (Connection con = DBUtil.getConnection();
             PrintWriter out = resp.getWriter()) {
            List<String> departments = readColumn(con, "SELECT department_name FROM departments ORDER BY department_name");
            List<String> companies = readColumn(con, "SELECT company_name FROM companies ORDER BY company_name");
            List<String> designations = readColumn(con, "SELECT designation_name FROM designations ORDER BY designation_name");
            List<String> locations = readColumn(con, "SELECT location_name FROM locations ORDER BY location_name");
            List<String> skills = readColumn(con, "SELECT skill_name FROM skills ORDER BY skill_name");
            List<String> employmentTypes = readColumn(con, "SELECT employment_type_name FROM employment_types ORDER BY employment_type_name");

            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"departments\":").append(toJsonArray(departments)).append(",");
            json.append("\"companies\":").append(toJsonArray(companies)).append(",");
            json.append("\"designations\":").append(toJsonArray(designations)).append(",");
            json.append("\"locations\":").append(toJsonArray(locations)).append(",");
            json.append("\"skills\":").append(toJsonArray(skills)).append(",");
            json.append("\"employmentTypes\":").append(toJsonArray(employmentTypes));
            json.append("}");
            out.write(json.toString());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private List<String> readColumn(Connection con, String sql) throws Exception {
        List<String> rows = new ArrayList<String>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(rs.getString(1));
            }
        }
        return rows;
    }

    private String toJsonArray(List<String> values) {
        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append("\"").append(escape(values.get(i))).append("\"");
        }
        json.append("]");
        return json.toString();
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}

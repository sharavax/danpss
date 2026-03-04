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

@WebServlet(name = "JobsReportServlet", urlPatterns = {"/reports/jobs"})
public class JobsReportServlet extends HttpServlet {

    private static final String JOBS_SQL =
            "SELECT job_id, post_type, title, company, location, job_type, posted_date " +
            "FROM jobs " +
            "WHERE (? = '' OR title LIKE CONCAT('%', ?, '%')) " +
            "AND (? = '' OR company LIKE CONCAT('%', ?, '%')) " +
            "AND (? = '' OR post_type = ?) " +
            "AND (? = '' OR location LIKE CONCAT('%', ?, '%')) " +
            "ORDER BY posted_date DESC, title ASC";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String title = nv(req.getParameter("title"));
        String company = nv(req.getParameter("company"));
        String postType = nv(req.getParameter("postType"));
        String location = nv(req.getParameter("location"));

        List<String[]> rows = new ArrayList<String[]>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(JOBS_SQL)) {

            ps.setString(1, title);
            ps.setString(2, title);
            ps.setString(3, company);
            ps.setString(4, company);
            ps.setString(5, postType);
            ps.setString(6, postType);
            ps.setString(7, location);
            ps.setString(8, location);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new String[]{
                            String.valueOf(rs.getInt("job_id")),
                            nv(rs.getString("post_type")),
                            nv(rs.getString("title")),
                            nv(rs.getString("company")),
                            nv(rs.getString("location")),
                            nv(rs.getString("job_type")),
                            String.valueOf(rs.getDate("posted_date"))
                    });
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("title", title);
        req.setAttribute("company", company);
        req.setAttribute("postType", postType);
        req.setAttribute("location", location);
        req.setAttribute("rows", rows);
        req.getRequestDispatcher("/reports/jobs-report.jsp").forward(req, resp);
    }

    private String nv(String value) {
        return value == null ? "" : value.trim();
    }
}

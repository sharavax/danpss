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

@WebServlet(name = "JobPostServlet", urlPatterns = {"/job/post"})
public class JobPostServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String postType = req.getParameter("jobPostType");
        String title = req.getParameter("jobTitle");
        String company = req.getParameter("jobCompany");
        String location = req.getParameter("jobLocation");
        String jobType = req.getParameter("jobJobType");
        String eligibility = req.getParameter("jobEligibility");
        String duration = req.getParameter("jobDuration");
        String stipend = req.getParameter("jobStipend");
        String postedDate = req.getParameter("jobPostedDate");

        String insert = "INSERT INTO jobs (post_type,title,company,location,job_type,eligibility,duration,stipend,posted_date) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(insert)){
            ps.setString(1, postType);
            ps.setString(2, title);
            ps.setString(3, company);
            ps.setString(4, location);
            ps.setString(5, jobType);
            ps.setString(6, eligibility);
            ps.setString(7, duration);
            ps.setString(8, stipend);
            ps.setString(9, postedDate);
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/index.html");
        } catch (Exception e){
            throw new ServletException(e);
        }
    }
}

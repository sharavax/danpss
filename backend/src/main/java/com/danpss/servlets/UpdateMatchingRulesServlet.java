package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.AccessControlUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Locale;

@WebServlet(name = "UpdateMatchingRulesServlet", urlPatterns = {"/admin/matching-rules"})
public class UpdateMatchingRulesServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = AccessControlUtil.requireRole(req, resp, "Placement Officer");
        if (session == null) {
            return;
        }

        String skillsWeightRaw = normalize(req.getParameter("skillsWeight"));
        String eligibilityWeightRaw = normalize(req.getParameter("eligibilityWeight"));
        String gradYearWeightRaw = normalize(req.getParameter("gradYearWeight"));
        String minScoreRaw = normalize(req.getParameter("minScore"));
        String maxRecommendationsRaw = normalize(req.getParameter("maxRecommendations"));

        Double skillsWeight = parseDecimal(skillsWeightRaw);
        Double eligibilityWeight = parseDecimal(eligibilityWeightRaw);
        Double gradYearWeight = parseDecimal(gradYearWeightRaw);
        Double minScore = parseDecimal(minScoreRaw);
        Integer maxRecommendations = parseInteger(maxRecommendationsRaw);

        if (skillsWeight == null || eligibilityWeight == null || gradYearWeight == null || minScore == null || maxRecommendations == null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer?error=rules_invalid_number");
            return;
        }

        if (!isBetweenZeroAndOne(skillsWeight.doubleValue())
                || !isBetweenZeroAndOne(eligibilityWeight.doubleValue())
                || !isBetweenZeroAndOne(gradYearWeight.doubleValue())
                || !isBetweenZeroAndOne(minScore.doubleValue())) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer?error=rules_out_of_range");
            return;
        }

        if (maxRecommendations.intValue() < 1 || maxRecommendations.intValue() > 20) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer?error=rules_max_invalid");
            return;
        }

        double totalWeight = skillsWeight.doubleValue() + eligibilityWeight.doubleValue() + gradYearWeight.doubleValue();
        if (Math.abs(totalWeight - 1.0d) > 0.0001d) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer?error=rules_weight_sum");
            return;
        }

        String[][] updates = new String[][]{
                {"skills_weight", formatDecimal(skillsWeight.doubleValue())},
                {"eligibility_weight", formatDecimal(eligibilityWeight.doubleValue())},
                {"graduation_year_weight", formatDecimal(gradYearWeight.doubleValue())},
                {"minimum_match_score", formatDecimal(minScore.doubleValue())},
                {"max_recommendations", String.valueOf(maxRecommendations)}
        };

        try (Connection con = DBUtil.getConnection()) {
            String sql = "UPDATE matching_rules SET rule_value = ? WHERE rule_key = ?";
            for (int i = 0; i < updates.length; i++) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, updates[i][1]);
                    ps.setString(2, updates[i][0]);
                    ps.executeUpdate();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/dashboard/officer?success=rules_updated");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private Double parseDecimal(String value) {
        try {
            return Double.valueOf(Double.parseDouble(value));
        } catch (Exception e) {
            return null;
        }
    }

    private Integer parseInteger(String value) {
        try {
            return Integer.valueOf(Integer.parseInt(value));
        } catch (Exception e) {
            return null;
        }
    }

    private boolean isBetweenZeroAndOne(double value) {
        return value >= 0.0d && value <= 1.0d;
    }

    private String formatDecimal(double value) {
        return String.format(Locale.US, "%.2f", value);
    }
}

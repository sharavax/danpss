<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%!
    private String safe(Object value) {
        if (value == null) {
            return "";
        }
        String text = String.valueOf(value);
        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jobs and Internship Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>`r`n                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/placement">Placement Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard">Dashboard</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell">
    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
            <span class="kicker">Report Module</span>
            <h1 class="section-title mb-1">Jobs and Internship Report</h1>
            <p class="section-muted mb-0">Search and filter opportunity data with unified placement analytics.</p>
        </div>
        <div class="d-flex gap-2 flex-wrap">
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/index.html">Home</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/placement">Placement Report</a>
        </div>
    </div>
    <% if (request.getAttribute("errorMessage") != null) { %>
    <div class="alert alert-danger"><%=safe(request.getAttribute("errorMessage"))%></div>
    <% } %>

    <div class="app-card mb-4">
        <form method="get" action="<%=request.getContextPath()%>/reports/jobs" class="row g-3">
            <div class="col-md-6 col-xl-3">
                <label class="form-label">Title</label>
                <input class="form-control" type="text" name="title" placeholder="Title" value="<%=safe(request.getAttribute("title"))%>"/>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Company</label>
                <input class="form-control" type="text" name="company" placeholder="Company" value="<%=safe(request.getAttribute("company"))%>"/>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Post Type</label>
                <select class="form-select" name="postType">
                    <option value="">All Post Types</option>
                    <option value="Job" <%= "Job".equals(request.getAttribute("postType")) ? "selected" : "" %>>Job</option>
                    <option value="Internship" <%= "Internship".equals(request.getAttribute("postType")) ? "selected" : "" %>>Internship</option>
                </select>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Job Type</label>
                <select class="form-select" name="jobType">
                    <option value="">All Job Types</option>
                    <option value="Full Time" <%= "Full Time".equals(request.getAttribute("jobType")) ? "selected" : "" %>>Full Time</option>
                    <option value="Part Time" <%= "Part Time".equals(request.getAttribute("jobType")) ? "selected" : "" %>>Part Time</option>
                    <option value="Internship" <%= "Internship".equals(request.getAttribute("jobType")) ? "selected" : "" %>>Internship</option>
                    <option value="Remote" <%= "Remote".equals(request.getAttribute("jobType")) ? "selected" : "" %>>Remote</option>
                </select>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Location</label>
                <input class="form-control" type="text" name="location" placeholder="Location" value="<%=safe(request.getAttribute("location"))%>"/>
            </div>
            <div class="col-md-6 col-xl-1 d-flex align-items-end">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
            </div>
            <div class="col-md-6 col-xl-2 d-flex align-items-end">
                <a class="btn btn-outline-secondary w-100" href="<%=request.getContextPath()%>/reports/jobs">Reset</a>
            </div>
        </form>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Visible Posts</div><div class="kpi-value"><%=safe(request.getAttribute("resultCount"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Total Jobs</div><div class="kpi-value"><%=safe(request.getAttribute("totalJobs"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Total Internships</div><div class="kpi-value"><%=safe(request.getAttribute("totalInternships"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Hiring Companies</div><div class="kpi-value"><%=safe(request.getAttribute("hiringCompanies"))%></div></div></div>
    </div>

    <div class="app-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="h5 mb-0">Opportunity Results</h2>
            <span class="badge badge-soft rounded-pill px-3 py-2"><%=safe(request.getAttribute("resultCount"))%> result(s)</span>
        </div>
        <div class="table-wrap">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Post Type</th>
                        <th>Title</th>
                        <th>Company</th>
                        <th>Location</th>
                        <th>Job Type</th>
                        <th>Eligibility</th>
                        <th>Duration</th>
                        <th>Stipend</th>
                        <th>Posted Date</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        List<String[]> rows = (List<String[]>) request.getAttribute("rows");
                        if (rows != null && !rows.isEmpty()) {
                            for (String[] row : rows) {
                    %>
                    <tr>
                        <td><%=safe(row[0])%></td>
                        <td><%=safe(row[1])%></td>
                        <td><%=safe(row[2])%></td>
                        <td><%=safe(row[3])%></td>
                        <td><%=safe(row[4])%></td>
                        <td><%=safe(row[5])%></td>
                        <td><%=safe(row[6])%></td>
                        <td><%=safe(row[7])%></td>
                        <td><%=safe(row[8])%></td>
                        <td><%=safe(row[9])%></td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr><td colspan="10" class="py-4"><div class="empty-state">No jobs or internships found for the selected filters.</div></td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Opportunity Intelligence Report</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>


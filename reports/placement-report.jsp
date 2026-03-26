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
    <title>Placement Analytics Report</title>
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
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/placement">Placement Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>`r`n                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard">Dashboard</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell">
    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
            <span class="kicker">Report Module</span>
            <h1 class="section-title mb-1">Placement Analytics Report</h1>
            <p class="section-muted mb-0">Track student placement performance and department/company-level trends.</p>
        </div>
        <div class="d-flex gap-2 flex-wrap">
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/index.html">Home</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a>
        </div>
    </div>
    <% if (request.getAttribute("errorMessage") != null) { %>
    <div class="alert alert-danger"><%=safe(request.getAttribute("errorMessage"))%></div>
    <% } %>

    <div class="app-card mb-4">
        <form method="get" action="<%=request.getContextPath()%>/reports/placement" class="row g-3">
            <div class="col-md-6 col-xl-3">
                <label class="form-label">Student Name</label>
                <input class="form-control" type="text" name="search" placeholder="Search student name" value="<%=safe(request.getAttribute("search"))%>"/>
            </div>
            <div class="col-md-6 col-xl-3">
                <label class="form-label">Department</label>
                <input class="form-control" type="text" name="department" placeholder="CSE / ECE / IT" value="<%=safe(request.getAttribute("department"))%>"/>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Graduation Year</label>
                <input class="form-control" type="text" name="graduationYear" placeholder="2026" value="<%=safe(request.getAttribute("graduationYear"))%>"/>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Company</label>
                <input class="form-control" type="text" name="company" placeholder="Company" value="<%=safe(request.getAttribute("company"))%>"/>
            </div>
            <div class="col-md-6 col-xl-1 d-flex align-items-end">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
            </div>
            <div class="col-md-6 col-xl-1 d-flex align-items-end">
                <a class="btn btn-outline-secondary w-100" href="<%=request.getContextPath()%>/reports/placement">Reset</a>
            </div>
        </form>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Total Students</div><div class="kpi-value"><%=safe(request.getAttribute("totalStudents"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Placed Students</div><div class="kpi-value"><%=safe(request.getAttribute("placedStudents"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Placement Rate</div><div class="kpi-value"><%=safe(request.getAttribute("placementRate"))%>%</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Matching Results</div><div class="kpi-value"><%=safe(request.getAttribute("resultCount"))%></div></div></div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-7">
            <div class="app-card h-100">
                <h2 class="h5">Placement Details</h2>
                <div class="table-wrap mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Department</th>
                                <th>Graduation Year</th>
                                <th>Company</th>
                                <th>Designation</th>
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
                            </tr>
                            <%      }
                                } else { %>
                            <tr><td colspan="7" class="py-4"><div class="empty-state">No records found for the selected filters.</div></td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="app-card mb-4">
                <h2 class="h5">Department Breakdown</h2>
                <div class="table-wrap mt-3">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                            <tr><th>Department</th><th>Total</th><th>Placed</th><th>Rate</th></tr>
                            </thead>
                            <tbody>
                            <%
                                List<String[]> departmentRows = (List<String[]>) request.getAttribute("departmentRows");
                                if (departmentRows != null && !departmentRows.isEmpty()) {
                                    for (String[] row : departmentRows) {
                            %>
                            <tr>
                                <td><%=safe(row[0])%></td>
                                <td><%=safe(row[1])%></td>
                                <td><%=safe(row[2])%></td>
                                <td><%=safe(row[3])%>%</td>
                            </tr>
                            <%      }
                                } else { %>
                            <tr><td colspan="4" class="py-4"><div class="empty-state">No department summary data available.</div></td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="app-card">
                <h2 class="h5">Top Hiring Companies</h2>
                <div class="table-wrap mt-3">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light"><tr><th>Company</th><th>Students Hired</th></tr></thead>
                            <tbody>
                            <%
                                List<String[]> companyRows = (List<String[]>) request.getAttribute("companyRows");
                                if (companyRows != null && !companyRows.isEmpty()) {
                                    for (String[] row : companyRows) {
                            %>
                            <tr>
                                <td><%=safe(row[0])%></td>
                                <td><%=safe(row[1])%></td>
                            </tr>
                            <%      }
                                } else { %>
                            <tr><td colspan="2" class="py-4"><div class="empty-state">No company summary data available.</div></td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Placement Performance and Trend Intelligence</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>


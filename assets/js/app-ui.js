(function () {
  function normalize(path) {
    return path.replace(/\/+$/, "") || "/";
  }

  function markActiveNav() {
    var current = normalize(window.location.pathname);
    document.querySelectorAll("[data-nav]").forEach(function (link) {
      var target = normalize(link.getAttribute("href") || "");
      if (!target) {
        return;
      }
      if (current === target || (target !== "/" && current.indexOf(target) === 0)) {
        link.classList.add("active");
        link.setAttribute("aria-current", "page");
      }
    });
  }

  function attachFieldClearOnInput() {
    document.querySelectorAll("form input, form select, form textarea").forEach(function (input) {
      input.addEventListener("input", function () {
        input.classList.remove("is-invalid");
      });
      input.addEventListener("change", function () {
        input.classList.remove("is-invalid");
      });
    });
  }

  function attachSubmitState() {
    document.querySelectorAll("form").forEach(function (form) {
      form.addEventListener("submit", function () {
        var submit = form.querySelector("button[type='submit'], input[type='submit']");
        if (!submit) {
          return;
        }
        submit.dataset.originalText = submit.dataset.originalText || submit.textContent;
        submit.textContent = "Processing...";
        submit.disabled = true;
        window.setTimeout(function () {
          if (submit.disabled) {
            submit.disabled = false;
            submit.textContent = submit.dataset.originalText;
          }
        }, 6000);
      });
    });
  }

  function initDateDefaults() {
    document.querySelectorAll("input[type='date'][data-default-today='true']").forEach(function (input) {
      if (!input.value) {
        input.value = new Date().toISOString().slice(0, 10);
      }
    });
  }

  function initBackToTop() {
    var button = document.createElement("button");
    button.type = "button";
    button.className = "back-to-top";
    button.setAttribute("aria-label", "Back to top");
    button.innerHTML = "&#8593;";
    document.body.appendChild(button);

    function syncVisibility() {
      if (window.scrollY > 240) {
        button.classList.add("show");
      } else {
        button.classList.remove("show");
      }
    }

    button.addEventListener("click", function () {
      window.scrollTo({ top: 0, behavior: "smooth" });
    });
    window.addEventListener("scroll", syncVisibility, { passive: true });
    syncVisibility();
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function createOptionMarkup(values, includeBlankLabel) {
    var html = "";
    if (includeBlankLabel) {
      html += '<option value="">' + escapeHtml(includeBlankLabel) + "</option>";
    }
    values.forEach(function (value) {
      html += '<option value="' + escapeHtml(value) + '"></option>';
    });
    return html;
  }

  function createSelectMarkup(values, includeBlankLabel) {
    var html = "";
    if (includeBlankLabel) {
      html += '<option value="">' + escapeHtml(includeBlankLabel) + "</option>";
    }
    values.forEach(function (value) {
      html += '<option value="' + escapeHtml(value) + '">' + escapeHtml(value) + "</option>";
    });
    return html;
  }

  function createPillChecks(values, name, idPrefix) {
    return values.map(function (value, index) {
      var safeId = idPrefix + "-" + index;
      return '' +
        '<div class="pill-check">' +
        '<input type="checkbox" id="' + escapeHtml(safeId) + '" name="' + escapeHtml(name) + '" value="' + escapeHtml(value) + '">' +
        '<label for="' + escapeHtml(safeId) + '">' + escapeHtml(value) + '</label>' +
        '</div>';
    }).join("");
  }

  function initLookupDrivenForms() {
    var needsLookups = document.querySelector("[data-needs-lookups]");
    if (!needsLookups) {
      return;
    }

    fetch("/danpss/api/lookups", { headers: { "Accept": "application/json" } })
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Lookup request failed");
        }
        return response.json();
      })
      .then(function (data) {
        var studentDepartment = document.getElementById("studentDepartment");
        if (studentDepartment) {
          studentDepartment.innerHTML = createSelectMarkup(data.departments || [], "Select department");
        }

        var alumniDepartment = document.getElementById("alumniDepartment");
        if (alumniDepartment) {
          alumniDepartment.innerHTML = createSelectMarkup(data.departments || [], "Select department");
        }

        var studentDesignationList = document.getElementById("studentDesignationList");
        if (studentDesignationList) {
          studentDesignationList.innerHTML = createOptionMarkup(data.designations || []);
        }

        var alumniDesignationList = document.getElementById("alumniDesignationList");
        if (alumniDesignationList) {
          alumniDesignationList.innerHTML = createOptionMarkup(data.designations || []);
        }

        var alumniCompanyList = document.getElementById("alumniCompanyList");
        if (alumniCompanyList) {
          alumniCompanyList.innerHTML = createOptionMarkup(data.companies || []);
        }

        var jobCompanyList = document.getElementById("jobCompanyList");
        if (jobCompanyList) {
          jobCompanyList.innerHTML = createOptionMarkup(data.companies || []);
        }

        var jobLocationList = document.getElementById("jobLocationList");
        if (jobLocationList) {
          jobLocationList.innerHTML = createOptionMarkup(data.locations || []);
        }

        var studentSkillChoices = document.getElementById("studentSkillChoices");
        if (studentSkillChoices) {
          studentSkillChoices.innerHTML = createPillChecks(data.skills || [], "studentSkillChoice", "student-skill");
        }

        var jobSkillChoices = document.getElementById("jobSkillChoices");
        if (jobSkillChoices) {
          jobSkillChoices.innerHTML = createPillChecks(data.skills || [], "jobSkillChoice", "job-skill");
        }

        var jobDepartmentChoices = document.getElementById("jobDepartmentChoices");
        if (jobDepartmentChoices) {
          jobDepartmentChoices.innerHTML = createPillChecks(data.departments || [], "jobDepartmentChoice", "job-department");
        }

        var jobEmploymentType = document.getElementById("jobJobType");
        if (jobEmploymentType && Array.isArray(data.employmentTypes)) {
          jobEmploymentType.innerHTML = createSelectMarkup(data.employmentTypes, null);
        }

        var reportDepartment = document.getElementById("reportDepartment");
        if (reportDepartment) {
          var selectedDepartment = reportDepartment.getAttribute("data-selected") || "";
          reportDepartment.innerHTML = createSelectMarkup(data.departments || [], "All departments");
          reportDepartment.value = selectedDepartment;
        }

        var reportCompanyList = document.getElementById("reportCompanyList");
        if (reportCompanyList) {
          reportCompanyList.innerHTML = createOptionMarkup(data.companies || []);
        }

        var reportJobsCompanyList = document.getElementById("reportJobsCompanyList");
        if (reportJobsCompanyList) {
          reportJobsCompanyList.innerHTML = createOptionMarkup(data.companies || []);
        }

        var reportLocationList = document.getElementById("reportLocationList");
        if (reportLocationList) {
          reportLocationList.innerHTML = createOptionMarkup(data.locations || []);
        }

        var reportJobType = document.getElementById("reportJobType");
        if (reportJobType && Array.isArray(data.employmentTypes)) {
          var selectedJobType = reportJobType.getAttribute("data-selected") || "";
          reportJobType.innerHTML = createSelectMarkup(data.employmentTypes, "All Job Types");
          reportJobType.value = selectedJobType;
        }

        document.dispatchEvent(new CustomEvent("danpss:lookups-loaded"));
      })
      .catch(function () {
        // Leave existing fallback content in place if lookups cannot be loaded.
      });
  }

  function populateYearSelect(element, selectedValue, startYear, endYear, blankLabel) {
    if (!element) {
      return;
    }
    var html = "";
    if (blankLabel) {
      html += '<option value="">' + escapeHtml(blankLabel) + "</option>";
    }
    for (var year = startYear; year <= endYear; year += 1) {
      html += '<option value="' + year + '">' + year + "</option>";
    }
    element.innerHTML = html;
    if (selectedValue) {
      element.value = selectedValue;
    }
  }

  function createYearChecks(container, name, idPrefix, startYear, endYear) {
    if (!container) {
      return;
    }
    var values = [];
    for (var year = startYear; year <= endYear; year += 1) {
      values.push(String(year));
    }
    container.innerHTML = createPillChecks(values, name, idPrefix);
  }

  function initStructuredYearInputs() {
    var currentYear = new Date().getFullYear();
    populateYearSelect(document.getElementById("studentGraduationYear"), "", currentYear - 1, currentYear + 6, "Select year");
    populateYearSelect(
      document.getElementById("alumniGraduationYear"),
      "",
      currentYear - 15,
      currentYear + 1,
      "Select year"
    );

    var reportGraduationYear = document.getElementById("reportGraduationYear");
    if (reportGraduationYear) {
      populateYearSelect(
        reportGraduationYear,
        reportGraduationYear.getAttribute("data-selected") || "",
        currentYear - 1,
        currentYear + 6,
        "All years"
      );
    }

    createYearChecks(document.getElementById("jobYearChoices"), "jobYearChoice", "job-year", currentYear - 1, currentYear + 3);
    document.dispatchEvent(new CustomEvent("danpss:lookups-loaded"));
  }

  document.addEventListener("DOMContentLoaded", function () {
    markActiveNav();
    attachFieldClearOnInput();
    attachSubmitState();
    initDateDefaults();
    initBackToTop();
    initStructuredYearInputs();
    initLookupDrivenForms();
  });
})();

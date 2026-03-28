function validateEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validatePhone(phone) {
    return /^[0-9]{10}$/.test(phone);
}

function validatePassword(password) {
    return password.length >= 6;
}

function isBlank(value) {
    return value.trim() === "";
}

function isYearInRange(value) {
    const year = Number(value);
    return Number.isInteger(year) && year >= 1990 && year <= 2100;
}

function isNonNegativeInteger(value) {
    const number = Number(value);
    return Number.isInteger(number) && number >= 0;
}

function showMessage(containerId, message, type) {
    const container = document.getElementById(containerId);
    if (!container) {
        return;
    }

    if (message) {
        container.textContent = message;
        container.classList.remove("d-none", "alert-danger", "alert-success", "alert-warning", "alert-info");
        container.classList.add(type || "alert-danger");
    } else {
        container.textContent = "";
        container.classList.add("d-none");
    }
}

function initFormStatus(containerId, messages) {
    const params = new URLSearchParams(window.location.search);
    const errorCode = params.get("error");
    const successCode = params.get("success");

    if (errorCode && messages[errorCode]) {
        showMessage(containerId, messages[errorCode], "alert-danger");
    } else if (successCode && messages[successCode]) {
        showMessage(containerId, messages[successCode], "alert-success");
    }
}

function setInvalid(inputId, message, containerId) {
    const input = document.getElementById(inputId);
    if (input) {
        input.classList.add("is-invalid");
        if (!input.dataset.feedbackId) {
            const feedback = input.parentElement ? input.parentElement.querySelector(".invalid-feedback") : null;
            if (feedback) {
                input.dataset.feedbackId = "inline";
            }
        }
        const inline = input.parentElement ? input.parentElement.querySelector(".invalid-feedback") : null;
        if (inline) {
            inline.textContent = message;
        }
        input.focus();
    }
    if (containerId) {
        showMessage(containerId, message, "alert-danger");
    }
    return false;
}

function validateRequired(inputs, containerId, message) {
    for (const inputId of inputs) {
        const element = document.getElementById(inputId);
        if (!element || isBlank(element.value || "")) {
            return setInvalid(inputId, message, containerId);
        }
    }
    return true;
}

function validateAlumniForm() {
    showMessage("alumniFormMessage", "");

    if (!validateRequired([
        "alumniName", "alumniEmail", "alumniPhone", "alumniGraduationYear", "alumniDepartment",
        "alumniCompany", "alumniDesignation", "alumniExperience", "alumniPass", "alumniCPass"
    ], "alumniFormMessage", "Please complete all required alumni details.")) {
        return false;
    }

    const email = document.getElementById("alumniEmail").value.trim();
    const phone = document.getElementById("alumniPhone").value.trim();
    const graduationYear = document.getElementById("alumniGraduationYear").value.trim();
    const experience = document.getElementById("alumniExperience").value.trim();
    const pass = document.getElementById("alumniPass").value;
    const cpass = document.getElementById("alumniCPass").value;

    if (!validateEmail(email)) {
        return setInvalid("alumniEmail", "Enter a valid email address.", "alumniFormMessage");
    }

    if (!validatePhone(phone)) {
        return setInvalid("alumniPhone", "Phone number must contain exactly 10 digits.", "alumniFormMessage");
    }

    if (!isYearInRange(graduationYear)) {
        return setInvalid("alumniGraduationYear", "Graduation year must be between 1990 and 2100.", "alumniFormMessage");
    }

    if (!isNonNegativeInteger(experience)) {
        return setInvalid("alumniExperience", "Experience must be a non-negative number.", "alumniFormMessage");
    }

    if (!validatePassword(pass)) {
        return setInvalid("alumniPass", "Password must contain at least 6 characters.", "alumniFormMessage");
    }

    if (pass !== cpass) {
        return setInvalid("alumniCPass", "Password and confirm password must match.", "alumniFormMessage");
    }

    return true;
}

function validateStudentForm() {
    showMessage("studentFormMessage", "");

    if (!validateRequired([
        "studentName", "studentEmail", "studentDepartment", "studentDesignation", "studentSkills"
    ], "studentFormMessage", "Please complete the required student profile fields.")) {
        return false;
    }

    const email = document.getElementById("studentEmail").value.trim();
    const phone = document.getElementById("studentPhone").value.trim();
    const graduationYear = document.getElementById("studentGraduationYear").value.trim();
    const experience = document.getElementById("studentExperience").value.trim();

    if (!validateEmail(email)) {
        return setInvalid("studentEmail", "Enter a valid email address.", "studentFormMessage");
    }

    if (phone !== "" && !validatePhone(phone)) {
        return setInvalid("studentPhone", "Phone number must contain exactly 10 digits.", "studentFormMessage");
    }

    if (graduationYear !== "" && !isYearInRange(graduationYear)) {
        return setInvalid("studentGraduationYear", "Graduation year must be between 1990 and 2100.", "studentFormMessage");
    }

    if (experience !== "" && !isNonNegativeInteger(experience)) {
        return setInvalid("studentExperience", "Experience must be a non-negative number.", "studentFormMessage");
    }

    return true;
}

function validateLogin() {
    const email = document.getElementById("loginEmail").value.trim();
    const pass = document.getElementById("loginPass").value;

    if (!validateEmail(email)) {
        return setInvalid("loginEmail", "Enter a valid email address.", "loginFormMessage");
    }

    if (pass === "") {
        return setInvalid("loginPass", "Password is required.", "loginFormMessage");
    }

    return true;
}

function toggleInternshipFields() {
    const postTypeInput = document.getElementById("jobPostType");
    const internshipSection = document.getElementById("internshipSection");
    const duration = document.getElementById("jobDuration");
    const stipend = document.getElementById("jobStipend");

    if (!postTypeInput || !internshipSection || !duration || !stipend) {
        return;
    }

    const internshipMode = postTypeInput.value === "Internship";
    internshipSection.classList.toggle("d-none", !internshipMode);
    duration.required = internshipMode;
    stipend.required = internshipMode;

    if (!internshipMode) {
        duration.value = "";
        stipend.value = "";
        duration.classList.remove("is-invalid");
        stipend.classList.remove("is-invalid");
    }
}

function validatePostForm() {
    showMessage("jobFormMessage", "");

    if (!validateRequired([
        "jobPostType", "jobTitle", "jobCompany", "jobLocation", "jobEligibility", "jobPostedDate"
    ], "jobFormMessage", "Please complete all required job details.")) {
        return false;
    }

    const postType = document.getElementById("jobPostType").value;
    const duration = document.getElementById("jobDuration").value.trim();
    const stipend = document.getElementById("jobStipend").value.trim();
    const postedDate = document.getElementById("jobPostedDate").value;

    if (postType !== "Job" && postType !== "Internship") {
        return setInvalid("jobPostType", "Select a valid post type.", "jobFormMessage");
    }

    if (postType === "Internship") {
        if (duration === "" || !isNonNegativeInteger(duration) || Number(duration) <= 0) {
            return setInvalid("jobDuration", "Internship duration must be a positive number.", "jobFormMessage");
        }

        if (isBlank(stipend)) {
            return setInvalid("jobStipend", "Duration and stipend are required for internships.", "jobFormMessage");
        }
    }

    if (Number.isNaN(Date.parse(postedDate))) {
        return setInvalid("jobPostedDate", "Enter a valid posted date.", "jobFormMessage");
    }

    return true;
}

function collectCheckedValues(name) {
    return Array.from(document.querySelectorAll('input[name="' + name + '"]:checked'))
        .map(function (input) { return input.value.trim(); })
        .filter(function (value) { return value !== ""; });
}

function syncStudentSkills() {
    const hidden = document.getElementById("studentSkills");
    if (!hidden) {
        return;
    }

    const checked = collectCheckedValues("studentSkillChoice");
    const custom = (document.getElementById("studentSkillCustom") || { value: "" }).value
        .split(",")
        .map(function (value) { return value.trim(); })
        .filter(function (value) { return value !== ""; });

    const merged = [];
    checked.concat(custom).forEach(function (value) {
        if (!merged.includes(value)) {
            merged.push(value);
        }
    });
    hidden.value = merged.join(", ");
}

function syncJobEligibility() {
    const target = document.getElementById("jobEligibility");
    if (!target) {
        return;
    }

    const departments = collectCheckedValues("jobDepartmentChoice");
    const years = collectCheckedValues("jobYearChoice");
    const skills = collectCheckedValues("jobSkillChoice");
    const notes = ((document.getElementById("jobEligibilityNotes") || { value: "" }).value || "").trim();

    const parts = [];
    if (departments.length > 0) {
        parts.push("Departments: " + departments.join(", "));
    }
    if (years.length > 0) {
        parts.push("Graduation Years: " + years.join(", "));
    }
    if (skills.length > 0) {
        parts.push("Preferred Skills: " + skills.join(", "));
    }
    if (notes !== "") {
        parts.push(notes);
    }
    target.value = parts.join(". ");
}

function validateRegisterForm() {
    if (!validateRequired(["regName", "regEmail", "regPhone", "regPass", "regCPass"], "registerFormMessage", "Please complete all required registration fields.")) {
        return false;
    }

    const email = document.getElementById("regEmail").value.trim();
    const phone = document.getElementById("regPhone").value.trim();
    const pass = document.getElementById("regPass").value;
    const cpass = document.getElementById("regCPass").value;

    if (!validateEmail(email)) {
        return setInvalid("regEmail", "Enter a valid email address.", "registerFormMessage");
    }

    if (!validatePhone(phone)) {
        return setInvalid("regPhone", "Phone number must contain exactly 10 digits.", "registerFormMessage");
    }

    if (!validatePassword(pass)) {
        return setInvalid("regPass", "Password must contain at least 6 characters.", "registerFormMessage");
    }

    if (pass !== cpass) {
        return setInvalid("regCPass", "Password and confirm password must match.", "registerFormMessage");
    }

    return true;
}

document.addEventListener("DOMContentLoaded", function () {
    initFormStatus("loginFormMessage", {
        invalid: "Invalid email or password.",
        server: "Unable to login right now. Please try again.",
        session_required: "Please login to continue.",
        registered: "Registration successful. You can login now.",
        alumni_registered: "Alumni registration successful. You can login now."
    });

    initFormStatus("registerFormMessage", {
        invalid: "Please complete all required registration fields.",
        invalid_email: "Enter a valid email address.",
        invalid_phone: "Phone number must contain exactly 10 digits.",
        password_mismatch: "Password and confirm password must match.",
        role: "Please select a valid role.",
        exists: "Account already exists with this email.",
        server: "Unable to register right now. Please try again.",
        registered: "Account created successfully."
    });
    const role = document.getElementById("role");
    if (role && role.value && !["Student", "Alumni", "Placement Officer"].includes(role.value)) {
        role.value = "Student";
    }
    const loginEmail = document.getElementById("loginEmail");
    if (loginEmail) {
        loginEmail.setAttribute("maxlength", "100");
    }

    const postType = document.getElementById("jobPostType");
    if (postType) {
        toggleInternshipFields();
        postType.addEventListener("change", toggleInternshipFields);
    }

    function wireDynamicLookupInputs() {
        document.querySelectorAll('input[name="studentSkillChoice"]').forEach(function (input) {
            input.addEventListener("change", syncStudentSkills);
        });
        const studentSkillCustom = document.getElementById("studentSkillCustom");
        if (studentSkillCustom) {
            studentSkillCustom.removeEventListener("input", syncStudentSkills);
            studentSkillCustom.addEventListener("input", syncStudentSkills);
            syncStudentSkills();
        }

        [
            'input[name="jobDepartmentChoice"]',
            'input[name="jobYearChoice"]',
            'input[name="jobSkillChoice"]'
        ].forEach(function (selector) {
            document.querySelectorAll(selector).forEach(function (input) {
                input.addEventListener("change", syncJobEligibility);
            });
        });
        const jobEligibilityNotes = document.getElementById("jobEligibilityNotes");
        if (jobEligibilityNotes) {
            jobEligibilityNotes.removeEventListener("input", syncJobEligibility);
            jobEligibilityNotes.addEventListener("input", syncJobEligibility);
            syncJobEligibility();
        }
    }

    wireDynamicLookupInputs();
    document.addEventListener("danpss:lookups-loaded", wireDynamicLookupInputs);
});

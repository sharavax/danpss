<<<<<<< HEAD
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
        session_required: "Please login to continue."
    });

    initFormStatus("registerFormMessage", {
        invalid: "Please complete all required registration fields.",
        invalid_email: "Enter a valid email address.",
        invalid_phone: "Phone number must contain exactly 10 digits.",
        password_mismatch: "Password and confirm password must match.",
        role: "Please select a valid role.",
        exists: "Account already exists with this email.",
        server: "Unable to register right now. Please try again."
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
});
=======
// ===============================
// DANPSS COMMON FORM VALIDATION
// ===============================

// EMAIL VALIDATION
function validateEmail(email){
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return pattern.test(email);
}

// PHONE VALIDATION (10 digits)
function validatePhone(phone){
    const pattern = /^[0-9]{10}$/;
    return pattern.test(phone);
}

// PASSWORD VALIDATION
function validatePassword(password){
    return password.length >= 6;
}

// ===============================
// ALUMNI REGISTRATION VALIDATION
// ===============================
function validateAlumniForm(){
    let name = document.getElementById("alumniName").value.trim();
    let email = document.getElementById("alumniEmail").value.trim();
    let phone = document.getElementById("alumniPhone").value.trim();
    let graduationYear = document.getElementById("alumniGraduationYear").value.trim();
    let department = document.getElementById("alumniDepartment").value.trim();
    let company = document.getElementById("alumniCompany").value.trim();
    let designation = document.getElementById("alumniDesignation").value.trim();
    let experience = document.getElementById("alumniExperience").value;
    let pass = document.getElementById("alumniPass").value;
    let cpass = document.getElementById("alumniCPass").value;

    if(name === ""){
        alert("Name required");
        return false;
    }

    if(!validateEmail(email)){
        alert("Invalid email");
        return false;
    }

    if(!validatePhone(phone)){
        alert("Phone must be 10 digits");
        return false;
    }

    if(graduationYear === "" || graduationYear < 1990 || graduationYear > 2100){
        alert("Please enter valid graduation year");
        return false;
    }

    if(department === ""){
        alert("Department required");
        return false;
    }

    if(company === ""){
        alert("Company name required");
        return false;
    }

    if(designation === ""){
        alert("Designation required");
        return false;
    }

    if(experience === "" || experience < 0){
        alert("Please enter valid experience");
        return false;
    }

    if(!validatePassword(pass)){
        alert("Password must be at least 6 characters");
        return false;
    }

    if(pass !== cpass){
        alert("Passwords do not match");
        return false;
    }

    return true;
}

// ===============================
// STUDENT PROFILE VALIDATION
// ===============================
function validateStudentForm(){
    let name = document.getElementById("studentName").value.trim();
    let email = document.getElementById("studentEmail").value.trim();
    let phone = document.getElementById("studentPhone").value.trim();
    let graduationYear = document.getElementById("studentGraduationYear").value.trim();
    let department = document.getElementById("studentDepartment").value.trim();
    let company = document.getElementById("studentCompany").value.trim();
    let designation = document.getElementById("studentDesignation").value.trim();
    let experience = document.getElementById("studentExperience").value;
    let skills = document.getElementById("studentSkills").value.trim();

    if(name === ""){
        alert("Student name required");
        return false;
    }

    if(email === ""){
        alert("Email required");
        return false;
    }

    if(!validateEmail(email)){
        alert("Invalid email format");
        return false;
    }

    if(phone !== "" && !validatePhone(phone)){
        alert("Phone must be 10 digits");
        return false;
    }

    if(graduationYear !== "" && (graduationYear < 1990 || graduationYear > 2100)){
        alert("Please enter valid graduation year");
        return false;
    }

    if(department === ""){
        alert("Department required");
        return false;
    }

    if(designation === ""){
        alert("Designation required");
        return false;
    }

    if(experience !== "" && experience < 0){
        alert("Experience cannot be negative");
        return false;
    }

    if(skills === ""){
        alert("Skills/Domain required");
        return false;
    }

    return true;
}

// ===============================
// LOGIN VALIDATION
// ===============================
function validateLogin(){
    let email = document.getElementById("loginEmail").value;
    let pass = document.getElementById("loginPass").value;

    if(!validateEmail(email)){
        alert("Enter valid email");
        return false;
    }

    if(pass === ""){
        alert("Password required");
        return false;
    }

    return true;
}

// ===============================
// JOB / INTERNSHIP VALIDATION
// ===============================
function validatePostForm(){
    let postType = document.getElementById("jobPostType").value;
    let title = document.getElementById("jobTitle").value.trim();
    let company = document.getElementById("jobCompany").value.trim();
    let location = document.getElementById("jobLocation").value.trim();
    let eligibility = document.getElementById("jobEligibility").value.trim();
    let duration = document.getElementById("jobDuration").value;
    let stipend = document.getElementById("jobStipend").value.trim();
    let postedDate = document.getElementById("jobPostedDate").value;

    if(title === ""){
        alert("Job Title required");
        return false;
    }

    if(company === ""){
        alert("Company name required");
        return false;
    }

    if(location === ""){
        alert("Location required");
        return false;
    }

    if(eligibility === ""){
        alert("Eligibility criteria required");
        return false;
    }

    // Only validate internship fields if Internship is selected
    if(postType === "Internship"){
        if(duration === "" || duration <= 0){
            alert("Duration must be positive");
            return false;
        }

        if(stipend === ""){
            alert("Stipend required for internships");
            return false;
        }
    }

    if(postedDate === ""){
        alert("Posted date required");
        return false;
    }

    return true;
}

// ===============================
// STUDENT / ALUMNI REGISTRATION VALIDATION
// ===============================
function validateRegisterForm(){
    let name = document.getElementById("regName").value;
    let email = document.getElementById("regEmail").value;
    let phone = document.getElementById("regPhone").value;
    let pass = document.getElementById("regPass").value;
    let cpass = document.getElementById("regCPass").value;

    if(name === ""){
        alert("Name required");
        return false;
    }

    if(!validateEmail(email)){
        alert("Invalid email");
        return false;
    }

    if(!validatePhone(phone)){
        alert("Phone must be 10 digits");
        return false;
    }

    if(!validatePassword(pass)){
        alert("Password must be at least 6 characters");
        return false;
    }

    if(pass !== cpass){
        alert("Passwords do not match");
        return false;
    }

    return true;
}
>>>>>>> 414849608c4551c6b8b230b4fd34394e9265c393

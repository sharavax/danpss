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
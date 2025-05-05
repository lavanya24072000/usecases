<?php
// Show PHP errors (for debugging)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
 
// DB connection variables
$host= "terraform-20250505165955580800000001.c74iaoqyw64r.us-east-2.rds.amazonaws.com";
$user = "admin";
$pass = "prashola";
$db= "testdb";

// Connect to DB
$conn = new mysqli($host, $user, $pass, $db);
 
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} else {
    echo "Connected successfully<br>";
}
 
// Handle form submit
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'];
    echo "You submitted: " . htmlspecialchars($name) . "<br>";
 
    $sql = "INSERT INTO users (name) VALUES ('$name')";
    if ($conn->query($sql) === TRUE) {
        echo "New record created successfully<br>";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}
?>
 
<h2>Enter Your Name</h2>
<form method="POST">
    <input type="text" name="name" required>
    <input type="submit" value="Submit">
</form>

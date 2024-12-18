<?php
$servername = 'localhost';
$username = 'root';
$password = '';  // Your MySQL root password here
$database = 'doctor_database';

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>

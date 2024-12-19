<?php
// Database connection settings
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Database connection code here...
include 'db_connection.php';


// Get the doctor ID from the query string (GET parameter)
$doctor_id = isset($_GET['doctor_id']) ? intval($_GET['doctor_id']) : 0;

// If no doctor ID is provided, return an error
if ($doctor_id <= 0) {
    echo json_encode(["error" => "No valid doctor ID provided"]);
    exit();
}

// Query to fetch data for a specific doctor
$query = "SELECT * FROM patients WHERE doctorId = $doctor_id";
$result = $conn->query($query);

// Initialize an empty array to store data
$data = array();

// Fetch the row for the specified doctor and store it in the $data array
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    // Return the data as JSON
    header('Content-Type: application/json');
    echo json_encode(["data" => $data]); // Return data in the 'data' field
} else {
    // If no rows are found for the specified doctor, return an empty array
    echo json_encode(["data" => []]);
}

// Close the connection
$conn->close();
?>

<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

// Database connection code here...
include 'db_connection.php'; // Make sure you have the database connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get the POST data
    $doctorId = $_POST['doctorId'] ?? null;
    $patientId = $_POST['patientId'] ?? null;
    $spermCount = $_POST['spermCount'] ?? null;

    // Validate input
    if (empty($doctorId) || empty($patientId) || empty($spermCount)) {
        echo json_encode(['success' => false, 'message' => 'Doctor ID, Patient ID, and Sperm Count are required.']);
        exit;
    }

    // Ensure sperm count is numeric
    if (!is_numeric($spermCount)) {
        echo json_encode(['success' => false, 'message' => 'Sperm count must be a number.']);
        exit;
    }

    // Prepare the SQL statement to store the sperm count
    $stmt = $conn->prepare("INSERT INTO sperm_counts (doctorId, patientId, sperm_count) VALUES (?, ?, ?)");
    $stmt->bind_param("ssi", $doctorId, $patientId, $spermCount);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Sperm count stored successfully!']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
    }
}
?>

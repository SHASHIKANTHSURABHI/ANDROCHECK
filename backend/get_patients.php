<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");
include 'db_connection.php'; // Include database connection

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get doctorId from the POST request
    $doctorId = $_POST['doctorId'];

    // Check for required fields
    if (empty($doctorId)) {
        echo json_encode(['success' => false, 'message' => 'Doctor ID is required.']);
        exit();
    }

    // Fetch patients for the doctor
    $stmt = $conn->prepare("SELECT patientId, name, age, mobile, image_path,sperm_count FROM patients WHERE doctorId = ?");
    $stmt->bind_param("s", $doctorId); // Use "s" if doctorId is a string; change to "i" if it's an integer
    $stmt->execute();
    $result = $stmt->get_result();

    $patients = [];
    while ($row = $result->fetch_assoc()) {
        $patients[] = $row; // Each row includes patientId, name, age, mobile, and image_path
    }

    echo json_encode(['success' => true, 'patients' => $patients]);

    $stmt->close();
}
$conn->close();
?>
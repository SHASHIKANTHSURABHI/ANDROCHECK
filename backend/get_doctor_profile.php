<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

include 'db_connection.php'; // Ensure this file correctly establishes the $conn connection

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Capture doctorId from query string
    $doctorId = isset($_GET['doctorId']) ? intval($_GET['doctorId']) : null; // Ensure it's treated as an integer

    // Check if doctorId is provided and valid
    if (!$doctorId) {
        echo json_encode(['success' => false, 'message' => 'Doctor ID is required.']);
        exit;
    }

    // Prepare the SQL statement to fetch the doctor's profile
    $stmt = $conn->prepare("SELECT doctorId, firstName, lastName, phone, email, dob, gender, doctor_image_path FROM doctors WHERE doctorId = ?");
    if (!$stmt) {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
        exit;
    }

    $stmt->bind_param("i", $doctorId);

    // Execute the query
    if ($stmt->execute()) {
        $result = $stmt->get_result();

        // Check if the doctor exists
        if ($result && $result->num_rows > 0) {
            $doctorProfile = $result->fetch_assoc();
            // Send the profile data as JSON
            echo json_encode(['success' => true, 'data' => $doctorProfile]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Doctor not found.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}
?>

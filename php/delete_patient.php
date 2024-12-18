<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

// Database connection settings
$servername = 'localhost';
$username = 'root';
$password = '';  // Your MySQL root password here
$dbname = 'doctor_database';

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Connection failed: ' . $conn->connect_error]));
}

// Handle the request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if patientId is set and is numeric
    if (!isset($_POST['patientId']) || !is_numeric($_POST['patientId'])) {
        echo json_encode(['success' => false, 'message' => 'Invalid patient ID provided.']);
        exit;
    }

    $patientId = intval($_POST['patientId']);

    // Retrieve the image path before deleting the patient
    $sql = "SELECT image_path FROM patients WHERE patientId = ?";
    $stmt = $conn->prepare($sql);
    
    if ($stmt === false) {
        echo json_encode(['success' => false, 'message' => 'SQL preparation error: ' . $conn->error]);
        exit;
    }

    // Bind and execute
    $stmt->bind_param("i", $patientId);
    $stmt->execute();
    $result = $stmt->get_result();

    // Check if the patient exists
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $imagePath = $row['image_path'];

        // Delete the patient record
        $deleteSql = "DELETE FROM patients WHERE patientId = ?";
        $deleteStmt = $conn->prepare($deleteSql);

        if ($deleteStmt === false) {
            echo json_encode(['success' => false, 'message' => 'SQL preparation error: ' . $conn->error]);
            exit;
        }

        $deleteStmt->bind_param("i", $patientId);

        if ($deleteStmt->execute()) {
            if ($deleteStmt->affected_rows > 0) {
                // Delete the image file if it exists
                if ($imagePath && file_exists($imagePath)) {
                    if (unlink($imagePath)) {
                        echo json_encode(['success' => true, 'message' => 'Patient and associated image deleted successfully.']);
                    } else {
                        echo json_encode(['success' => false, 'message' => 'Patient deleted, but failed to delete the image file.']);
                    }
                } else {
                    echo json_encode(['success' => true, 'message' => 'Patient deleted successfully. Image file not found.']);
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'No patient found with the given ID.']);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Error executing query: ' . $deleteStmt->error]);
        }

        $deleteStmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'No patient found with the given ID.']);
    }

    $stmt->close();
}

// Close connection
$conn->close();
?>

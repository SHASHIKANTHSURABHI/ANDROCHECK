<?php
// Store sperm count in patients table
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Getting the input parameters
    $doctorId = $_POST['doctorId'];
    $patientId = $_POST['patientId'];
    $spermCount = $_POST['spermCount'];

    // Validate inputs to avoid SQL injection and ensure valid values
    if (empty($doctorId) || empty($patientId) || !is_numeric($spermCount)) {
        $response = [
            'success' => false,
            'message' => 'Invalid input values. Please check the data.'
        ];
        echo json_encode($response);
        exit;
    }

    // Update sperm count in the patients table using the provided doctorId and patientId
    $query = "UPDATE patients SET sperm_count = '$spermCount' 
              WHERE doctorId = '$doctorId' AND patientId = '$patientId'";

    $result = mysqli_query($conn, $query);

    if ($result) {
        $response = [
            'success' => true,
            'message' => 'Sperm count saved successfully.'
        ];
    } else {
        // Improved error message with more details for debugging
        $response = [
            'success' => false,
            'message' => 'Failed to save sperm count. Error: ' . mysqli_error($conn)
        ];
    }

    echo json_encode($response);
}
?>

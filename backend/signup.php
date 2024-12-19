<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");
include 'db_connection.php'; // Ensure this file connects to your database

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Email and password are required.']);
        exit();
    }

    // Check if email already exists
    $stmt = $conn->prepare("SELECT * FROM doctors WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Email already exists.']);
    } else {
        // Insert new user
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO doctors (email, password) VALUES (?, ?)");
        $stmt->bind_param("ss", $email, $hashedPassword);

        if ($stmt->execute()) {
            $doctorId = $stmt->insert_id; // Get the inserted doctor ID
            echo json_encode(['success' => true, 'doctorId' => $doctorId]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error inserting record.']);
        }
    }

    $stmt->close();
}
$conn->close();
?>

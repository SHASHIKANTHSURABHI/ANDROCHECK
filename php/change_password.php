<?php
// change_password.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

include('db_connection.php'); // Assuming this contains your database connection code

if (isset($_POST['doctorId']) && isset($_POST['oldPassword']) && isset($_POST['newPassword'])) {
    $doctorId = $_POST['doctorId'];
    $oldPassword = $_POST['oldPassword'];
    $newPassword = $_POST['newPassword'];

    // Debugging: print the incoming parameters
    echo "Received doctorId: $doctorId\n";
    echo "Received oldPassword: $oldPassword\n";

    // Check if the doctorId exists in the database
    $query = "SELECT * FROM doctors WHERE doctorId = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $doctorId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $doctor = $result->fetch_assoc();

        // If passwords are stored in hash format, use password_verify
        if (password_verify($oldPassword, $doctor['password'])) {
            // Hash the new password before updating
            $newPasswordHash = password_hash($newPassword, PASSWORD_DEFAULT);

            $updateQuery = "UPDATE doctors SET password = ? WHERE doctorId = ?";
            $updateStmt = $conn->prepare($updateQuery);
            $updateStmt->bind_param("ss", $newPasswordHash, $doctorId);
            
            if ($updateStmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'Password changed successfully']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Failed to update password']);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid old password']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid doctorId']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
}

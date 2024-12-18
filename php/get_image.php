<?php
header("Content-Type: image/jpeg");
include 'db_connection.php'; // Include your database connection if necessary

// Define the directory where images are stored
$baseDir = __DIR__ . '/images/'; // Adjust the 'images/' directory as needed

// Check if the 'filename' parameter is provided
if (isset($_GET['filename'])) {
    // Sanitize the filename to prevent directory traversal
    $filename = basename($_GET['filename']);
    $filepath = $baseDir . $filename;

    // Check if the file exists and is a JPEG image
    if (file_exists($filepath) && mime_content_type($filepath) === 'image/jpeg') {
        // Output the image file content
        header("Content-Length: " . filesize($filepath));
        readfile($filepath);
        exit;
    } else {
        // If the file doesn't exist or is not a JPEG, send a 404 response
        http_response_code(404);
        echo json_encode(['error' => 'Image not found']);
        exit;
    }
} else {
    // If no filename is provided, send a 400 response
    http_response_code(400);
    echo json_encode(['error' => 'No filename provided']);
    exit;
}
?>

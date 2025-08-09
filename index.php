<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Little Geeky</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center h-screen">
    <div class="bg-white shadow-2xl rounded-2xl p-10 text-center">
        <h1 class="text-5xl font-extrabold text-purple-700 mb-6">🤓 Little Geeky Repo!</h1>
        <p class="text-gray-700">Your geeky test PHP + TailwindCSS setup is alive.</p>
        <p class="mt-4 text-green-600 font-semibold">✅ Environment is working perfectly</p>
        <?php echo "<p class='mt-3 text-sm text-gray-500'>PHP says hello from the server side!</p>"; ?>
    </div>
</body>
</html>
EOF
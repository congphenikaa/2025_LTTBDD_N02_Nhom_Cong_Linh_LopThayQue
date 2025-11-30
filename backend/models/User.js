import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true, // Email không được trùng
    },
    password: {
        type: String, // Có thể null nếu đăng nhập bằng Google
    },
    avatar: {
        type: String, // Lưu đường dẫn ảnh đại diện
        default: "",
    },
    googleId: {
        type: String, // ID riêng của Google (nếu có)
    },
    // Sau này có thể thêm favorites: [], playlist: []...
}, { timestamps: true });

const User = mongoose.model("User", userSchema);
export default User;
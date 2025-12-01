import admin from "../configs/firebase";
import User from "../models/User.js";

export const verifyAdmin = async (req, res ,next) => {
    try {
        // 1. Lấy token tu header (client gửi lên: header : {Authorization: "Bearer <token>"})
        const token = req.headers.authorization?.split(" ")[1];

        if(!token) {
            return res.status(401).json({ message: "Không tìm thấy Token xác thực"});
        }

        // 2. Xác thực token với firebase
        const decodedToken = await admin.auth().verifyIdToken(token);
        const email = decodedToken.email;

        // 3. Tim User trong DB để xem Role
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: "Người dùng không tồn tại"});
        }

        // 4. Kiemr tra quyen admin
        if(user.role !== "admin"){
            return res.status(403).json({ message: "Từ chối quyền truy cập! Bạn không phải là admin"});
        }

        // 5. Nếu là Admin, cho phép đi tiếp
        req.user = user;
        next();

    } catch (error) {
        console.error("Auth Middleware Error:", error);
        return res.status(401).json({ message: "Token không hợp lệ hoặc đã hết hạn"});
    }
}
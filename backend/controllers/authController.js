import User from "../models/User.js";
import admin from "../configs/firebase.js";

// === HÀM BỔ TRỢ: Xác thực Token với Firebase ===
const verifyFirebaseToken = async (token) => {
    try {
        if (!token) return null;
        // Hỏi Firebase: Token này của ai?
        const decodedToken = await admin.auth().verifyIdToken(token);
        return decodedToken;
    } catch (error) {
        return null;
    }
};

// 1. ĐĂNG KÝ (Email/Password)
// Flow: Flutter đăng ký Firebase xong -> Gửi Token + Tên lên đây -> Node.js lưu vào MongoDB
const registerUser = async (req, res) => {
    try {
        const { token, fullName } = req.body;

        // Bước 1: Xác thực Token
        const decoded = await verifyFirebaseToken(token);
        if (!decoded) {
            return res.status(401).json({ success: false, message: "Token không hợp lệ" });
        }

        const email = decoded.email;
        const uid = decoded.uid;

        // Bước 2: Kiểm tra xem User đã tồn tại trong MongoDB chưa
        const exists = await User.findOne({ email });
        if (exists) {
            return res.status(400).json({ success: false, message: "Tài khoản đã được liên kết trong hệ thống" });
        }

        // Bước 3: Tạo User mới trong MongoDB
        const newUser = new User({
            email,
            fullName: fullName || "User", // Lấy tên từ Flutter gửi lên
            googleId: uid, // Lưu UID Firebase để tham chiếu
            avatar: decoded.picture || "",
            role: "user"
        });

        await newUser.save();
        
        console.log(`[REGISTER] Đã tạo user mới: ${email}`);
        res.status(201).json({ success: true, message: "Đăng ký thành công", data: newUser });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Lỗi Server" });
    }
}

// 2. ĐĂNG NHẬP (Email/Password)
// Flow: Flutter đăng nhập Firebase xong -> Gửi Token lên đây -> Node.js trả về dữ liệu User
const loginUser = async (req, res) => {
    try {
        const { token } = req.body;

        // Bước 1: Xác thực Token
        const decoded = await verifyFirebaseToken(token);
        if (!decoded) {
            return res.status(401).json({ success: false, message: "Token không hợp lệ hoặc hết hạn" });
        }

        // Bước 2: Tìm User trong MongoDB
        const user = await User.findOne({ email: decoded.email });

        if (!user) {
            // Trường hợp hy hữu: Có trên Firebase nhưng chưa có trong MongoDB (do lỗi lúc đăng ký)
            // Ta có thể báo lỗi hoặc tự động tạo mới (tùy logic của bạn)
            return res.status(404).json({ success: false, message: "Không tìm thấy thông tin người dùng trong hệ thống" });
        }

        res.status(200).json({ 
            success: true, 
            message: "Đăng nhập thành công", 
            token: user._id, 
            data: user 
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Lỗi Server" });
    }
}

// 3. ĐĂNG NHẬP GOOGLE (Tự động đồng bộ)
// Flow: Flutter lấy Token Google -> Gửi lên đây -> Có thì trả về, chưa có thì tạo mới
const syncGoogleUser = async (req, res) => {
    try {
        const { token } = req.body;
        const decoded = await verifyFirebaseToken(token);
        
        if (!decoded) return res.status(401).json({ success: false, message: "Token lỗi" });

        let user = await User.findOne({ email: decoded.email });

        if (!user) {
            user = new User({
                email: decoded.email,
                fullName: decoded.name || "Google User",
                avatar: decoded.picture || "",
                googleId: decoded.uid,
                role: "user"
            });
            await user.save();
            console.log(`[GOOGLE] Tạo mới: ${decoded.email}`);
        }

        res.status(200).json({ success: true, data: user });

    } catch (error) {
        res.status(500).json({ success: false, message: "Lỗi Sync Google" });
    }
}

export { registerUser, loginUser, syncGoogleUser };
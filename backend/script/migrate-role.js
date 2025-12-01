import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "../models/User.js"; 

// Chỉ định đường dẫn file .env nếu cần thiết
dotenv.config(); 
// Hoặc: dotenv.config({ path: "../.env" });

const debugRoles = async () => {
  try {
    if (!process.env.MONGODB_URI) {
      throw new Error("❌ Thiếu biến MONGODB_URI");
    }

    await mongoose.connect(process.env.MONGODB_URI);
    console.log("------------------------------------------------");
    console.log("✅ KẾT NỐI THÀNH CÔNG!");
    
    // 1. Kiểm tra đang nối vào Database nào?
    console.log(`📂 Database hiện tại: "${mongoose.connection.name}"`);

    // 2. Kiểm tra đang trọc vào Collection nào?
    console.log(`📚 Collection đang dùng: "${User.collection.name}"`);

    // 3. Đếm xem có bao nhiêu user trong collection này?
    const totalUsers = await User.countDocuments();
    console.log(`👥 Tổng số User tìm thấy: ${totalUsers}`);

    // 4. Đếm xem bao nhiêu user CHƯA có role?
    const noRoleUsers = await User.countDocuments({ role: { $exists: false } });
    console.log(`⚠️ Số User chưa có role: ${noRoleUsers}`);

    if (noRoleUsers > 0) {
        console.log("🚀 Đang tiến hành cập nhật...");
        const result = await User.updateMany(
            { role: { $exists: false } }, 
            { $set: { role: "user" } }    
        );
        console.log(`🎉 Kết quả: Đã sửa ${result.modifiedCount} dòng.`);
    } else {
        console.log("✅ Tất cả user đã có role, không cần làm gì cả.");
    }
    console.log("------------------------------------------------");

  } catch (error) {
    console.error("❌ Lỗi:", error);
  } finally {
    mongoose.connection.close();
  }
};

debugRoles();
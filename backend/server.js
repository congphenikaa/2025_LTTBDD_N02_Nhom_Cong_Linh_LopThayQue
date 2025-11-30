import express from 'express'
import cors from 'cors'
import 'dotenv/config'
import connectDB from './configs/mongodb.js'
import authRouter from './routes/authRoute.js'
import connectCloudinary from './configs/cloudinary.js'

const app = express()

await connectDB()
await connectCloudinary()

app.use(cors())

app.use(express.json())
app.use('/api/auth', authRouter)

app.get('/', (req, res) => response.send("API Working"))


const PORT = process.env.PORT || 5000
app.listen(PORT, ()=>{
  console.log(`Server is running on port ${PORT}`)
})
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import validator from "validator";

const userSchema = new mongoose.Schema(
    {
        userName: {
            type: String,
            trim: true,
            minlength: [2, "Name must be at least 2 characters long"],
            maxlength: [50, "Name cannot exceed 50 characters"],
            validate: {
                validator: (value) => validator.matches(value.trim(), /^[a-zA-Z\s]*$/),
                message: "Name must contain only letters and spaces",
            },
        },
        email: {
            type: String,
            unique: true,
            trim: true,
            lowercase: true,
            minlength: [5, "Email must be at least 5 characters long"],
            maxlength: [254, "Email cannot exceed 254 characters"],
            validate: {
                validator: validator.isEmail,
                message: "Invalid email format",
            },
        },
        phoneNumber: {
            type: String,
            trim: true,
            minlength: [10, "Phone number must be 10 digits long"],
            maxlength: [10, "Phone number must be 10 digits long"],
            validate: {
                validator: (value) => validator.isMobilePhone(value, "any"),
                message: "Invalid phone number format",
            },
        },
        password: {
            type: String,
            trim: true,
            minlength: [8, "Password must be at least 8 characters long"],
            validate: {
                validator: (value) => {
                    if (value.startsWith("$2")) return true; // skip hashed
                    return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/.test(
                        value
                    );
                },
                message:
                    "Password must contain at least one uppercase, one lowercase, one number, and one special character",
            },
            select: false,
        },
        role: {
            type: String,
            enum: ["EndUser", "Receiver"],
            required: true,
            default: "EndUser",
        },
        isActive: {
            type: Boolean,
            default: true,
        },
        lastLogin: {
            type: Date,
            default: null,
        },
        passwordChangedAt: {
            type: Date,
            default: null,
        },

        // 🔗 Relationships (for future expansion)
        requests: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Request", // EndUser → requests they created
            },
        ],
        assignedRequests: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Request", // Receiver → requests assigned for review
            },
        ],
    },
    { timestamps: true }
);

// 🔒 Hash password before save
userSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();

    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);

        this.passwordChangedAt = Date.now();
        next();
    } catch (err) {
        next(err);
    }
});

// 🔑 Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model("User", userSchema);
export default User;

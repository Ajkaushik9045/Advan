import mongoose from "mongoose";

const itemSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, "Item name is required"],
            trim: true,
            unique: true,
        },
        quantity: {
            type: Number,
            required: true,
            min: 1,
        },
        description: {
            type: String,
            trim: true,
            maxlength: [500, "Description cannot exceed 500 characters"],
        },
        addedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // Receiver who added the item
            required: true,
        },
        isActive: {
            type: Boolean,
            default: true,
        },
    },
    { timestamps: true }
);

const Item = mongoose.model("Item", itemSchema);
export default Item;

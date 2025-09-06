import mongoose from "mongoose";

const requestItemSchema = new mongoose.Schema(
    {
        item: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Item",
            required: true,
        },
        quantity: {
            type: Number,
            required: true,
            min: 1,
        },
        available: {
            type: Boolean,
            default: false, // Initially not available
        },
        confirmedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // Receiver confirming this item
        },
    },
    { _id: false }
);

const requestSchema = new mongoose.Schema(
    {
        requester: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // End User who created the request
            required: true,
        },
        items: [requestItemSchema], // Array of items in the request
        status: {
            type: String,
            enum: ["Pending", "PartiallyFulfilled", "Confirmed"],
            default: "Pending",
        },
        assignedTo: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // Receiver assigned to handle request
        },
        notes: {
            type: String,
            trim: true,
            maxlength: [500, "Notes cannot exceed 500 characters"],
        },
    },
    { timestamps: true }
);

/**
 * Instance method to update request status based on item availability
 */
requestSchema.methods.updateStatus = function () {
    if (this.items.every((i) => i.available)) {
        this.status = "Confirmed";
    } else if (this.items.some((i) => i.available)) {
        this.status = "PartiallyFulfilled";
    } else {
        this.status = "Pending";
    }
    return this.save();
};

const Request = mongoose.model("Request", requestSchema);
export default Request;

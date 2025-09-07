import mongoose from "mongoose";

const assignmentHistorySchema = new mongoose.Schema(
  {
    request: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Request",
      required: true,
    },
    item: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Item",
      required: false, // Optional - for item-specific reassignments
    },
    reassignedFrom: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // Previous receiver
      required: true,
    },
    reassignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // New receiver
      required: true,
    },
    reason: {
      type: String,
      required: true,
      trim: true,
      maxlength: [500, "Reason cannot exceed 500 characters"],
    },
    status: {
      type: String,
      enum: ["Pending", "Accepted", "Rejected"],
      default: "Pending",
    },
    notes: {
      type: String,
      trim: true,
      maxlength: [1000, "Notes cannot exceed 1000 characters"],
    },
    reassignedAt: {
      type: Date,
      default: Date.now,
    },
    acceptedAt: {
      type: Date,
      default: null,
    },
    rejectedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);


// Virtual for duration between reassignment and acceptance
assignmentHistorySchema.virtual("processingTime").get(function () {
  if (this.acceptedAt) {
    return this.acceptedAt - this.reassignedAt;
  }
  return null;
});

// Ensure virtual fields are serialized
assignmentHistorySchema.set("toJSON", { virtuals: true });
assignmentHistorySchema.set("toObject", { virtuals: true });

const AssignmentHistory = mongoose.model(
  "AssignmentHistory",
  assignmentHistorySchema
);
export default AssignmentHistory;

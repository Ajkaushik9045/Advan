import Request from "../models/Request.js";
import User from "../models/User.models.js";
import AssignmentHistory from "../models/AssignmentHistory.js"; // keep track of reassignments


export const updateRequestStatus = async (requestId) => {
  const request = await Request.findById(requestId);
  if (!request) throw new Error("Request not found");

  const totalItems = request.items.length;
  const confirmedItems = request.items.filter((i) => i.available).length;

  if (confirmedItems === 0) {
    request.status = "Pending";
  } else if (confirmedItems === totalItems) {
    request.status = "Confirmed";
  } else {
    request.status = "PartiallyFulfilled";

    // 🔁 Reassign unconfirmed items to another receiver
    const unconfirmedItems = request.items.filter((i) => !i.available);
    if (unconfirmedItems.length > 0) {
      // Find another available receiver
      const alternativeReceiver = await User.findOne({
        role: "Receiver",
        isActive: true,
        _id: { $ne: request.assignedTo }, // Different from current receiver
      }).sort({ assignedRequests: 1 });

      if (alternativeReceiver) {
        // Update request assignment
        request.assignedTo = alternativeReceiver._id;

        // Update receiver's assigned requests
        await User.findByIdAndUpdate(alternativeReceiver._id, {
          $push: { assignedRequests: request._id },
        });

        // Remove from previous receiver's assigned requests
        await User.findByIdAndUpdate(request.assignedTo, {
          $pull: { assignedRequests: request._id },
        });

        // Log reassignment
        await AssignmentHistory.create({
          request: request._id,
          reassignedFrom: request.assignedTo,
          reassignedTo: alternativeReceiver._id,
          reason: "Partial fulfillment - unconfirmed items reassigned",
        });
      }
    }
  }

  await request.save();
};

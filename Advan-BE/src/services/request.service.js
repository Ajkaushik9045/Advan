import Request from "../models/Request.js";

/**
 * Update request status based on items availability
 * Call this whenever a receiver confirms items
 */
export const updateRequestStatus = async (requestId) => {
    const request = await Request.findById(requestId);
    if (!request) throw new Error("Request not found");

    const totalItems = request.items.length;
    const availableItems = request.items.filter((i) => i.available).length;

    if (availableItems === 0) request.status = "Pending";
    else if (availableItems === totalItems) request.status = "Confirmed";
    else request.status = "PartiallyFulfilled";

    await request.save();
};

function generateOrder(number)

neg = -1.* ones(1,number/2);
pos = ones(1,number/2);

participant_order = Shuffle([neg,pos]);

save('Y:\Neurofeedback\DecNef02\experiment\participant_order.mat', 'participant_order')
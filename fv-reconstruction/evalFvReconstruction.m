function evalFvReconstruction(fileID, gt, seg, res, iouThr, description)
    fprintf(fileID, "%s\n", description);
    for iou = iouThr
        [~, ~, ~, TPs, FPs, FNs] = evalDetection(seg, gt, iou, false, true);
        [~, ~, ~, TPr, FPr, FNr] = evalDetection(res, gt, iou, false, false);
        fprintf(fileID, "IOU %d\n", iou);
        fprintf(fileID, "seg: TP: %d, FP: %d, FN: %d\n", TPs, FPs, FNs);
        fprintf(fileID, "res : TP: %d, FP: %d, FN: %d\n", TPr, FPr, FNr);
    end
    fprintf(fileID, "\n");
end
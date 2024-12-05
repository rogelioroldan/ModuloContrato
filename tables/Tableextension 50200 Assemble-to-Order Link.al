tableextension 50200 "Tracking Specification Ext" extends "Tracking Specification"
{
    procedure InitFromContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        Init();
        SetItemData(
            ContratoPlanningLine."No.", ContratoPlanningLine.Description, ContratoPlanningLine."Location Code", ContratoPlanningLine."Variant Code",
            ContratoPlanningLine."Bin Code", ContratoPlanningLine."Qty. per Unit of Measure");
        SetSource(
            Database::"Contrato Planning Line", ContratoPlanningLine.Status.AsInteger(), ContratoPlanningLine."Job No.", ContratoPlanningLine."Job Contract Entry No.", '', 0);
        SetQuantities(
            ContratoPlanningLine."Remaining Qty. (Base)", ContratoPlanningLine."Remaining Qty.", ContratoPlanningLine."Remaining Qty. (Base)",
            ContratoPlanningLine."Remaining Qty.", ContratoPlanningLine."Remaining Qty. (Base)",
            ContratoPlanningLine."Quantity" - ContratoPlanningLine."Remaining Qty.",
            ContratoPlanningLine."Quantity (Base)" - ContratoPlanningLine."Remaining Qty. (Base)");

        OnAfterInitFromContratoPlanningLine(Rec, ContratoPlanningLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromContratoPlanningLine(var TrackingSpecification: Record "Tracking Specification"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;
}
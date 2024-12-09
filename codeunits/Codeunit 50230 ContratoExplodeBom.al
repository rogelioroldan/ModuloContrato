codeunit 50230 "Contrato-Explode BOM"
{
    TableNo = "Contrato Planning Line";

    trigger OnRun()
    var
        AssembleToOrderLink: Record "Assemble-to-OrderLinkContrato";
        HideDialog: Boolean;
    begin
        Contrato.Get(Rec."Contrato No.");

        CheckContratoPlanningLine(Rec);
        DeleteReservEntries(Rec);

        FromBOMComp.SetRange("Parent Item No.", Rec."No.");
        NoOfBOMComp := FromBOMComp.Count();

        if not HideDialog then
            if NoOfBOMComp = 0 then
                Error(ItemNotBOMErr, Rec."No.");

        ToContratoPlanningLine := Rec;
        FromBOMComp.SetRange(Type, FromBOMComp.Type::Item);
        FromBOMComp.SetFilter("No.", '<>%1', '');
        if FromBOMComp.FindSet() then
            repeat
                FromBOMComp.TestField(Type, FromBOMComp.Type::Item);
                Item.Get(FromBOMComp."No.");
                AssingContratoPlannigLineDataFromBOMComp();
            until FromBOMComp.Next() = 0;

        if Rec."BOM Item No." = '' then
            BOMItemNo := Rec."No."
        else
            BOMItemNo := Rec."BOM Item No.";

        if Rec.Type = Rec.Type::Item then
            AssembleToOrderLink.DeleteAsmFromContratoPlanningLine(Rec);

        InitParentItemLine(Rec);
        AddExtText();
        ExplodeBOMCompLines(Rec);
    end;

    var
        ToContratoPlanningLine: Record "Contrato Planning Line";
        FromBOMComp: Record "BOM Component";
        Contrato: Record Contrato;
        ItemTranslation: Record "Item Translation";
        Item: Record Item;
        Resource: Record Resource;
        UOMMgt: Codeunit "Unit of Measure Management";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ReservMgt: Codeunit "Reservation Management";
        BOMItemNo: Code[20];
        LineSpacing: Integer;
        NextLineNo: Integer;
        NoOfBOMComp: Integer;

        ItemNotBOMErr: Label 'Item %1 is not a BOM.', Comment = '%1 = Item No.';
        NotEnoughSpaceMsg: Label 'There is not enough space to explode the BOM.';

    procedure CallExplodeBOMCompLines(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ExplodeBOMCompLines(ContratoPlanningLine);
    end;

    local procedure ExplodeBOMCompLines(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        PreviousContratoPlanningLine: Record "Contrato Planning Line";
        InsertLinesBetween: Boolean;
    begin
        SetFiltersOnContratoPlanningLine(ContratoPlanningLine);
        ToContratoPlanningLine := ContratoPlanningLine;
        NextLineNo := ContratoPlanningLine."Line No.";
        InsertLinesBetween := false;
        if ToContratoPlanningLine.Find('>') then
            if ToContratoPlanningLine.IsExtendedText() and (ToContratoPlanningLine."Attached to Line No." = ContratoPlanningLine."Line No.") then begin
                ToContratoPlanningLine.SetRange("Attached to Line No.", ContratoPlanningLine."Line No.");
                ToContratoPlanningLine.FindLast();
                ToContratoPlanningLine.SetRange("Attached to Line No.");
                NextLineNo := ToContratoPlanningLine."Line No.";
                InsertLinesBetween := ToContratoPlanningLine.Find('>');
            end else
                InsertLinesBetween := true;
        GenerateLineSpacing(InsertLinesBetween);

        FromBOMComp.Reset();
        FromBOMComp.SetRange("Parent Item No.", ContratoPlanningLine."No.");
        FromBOMComp.FindSet();
        repeat
            ToContratoPlanningLine.Init();
            NextLineNo := NextLineNo + LineSpacing;
            ToContratoPlanningLine."Line No." := NextLineNo;
            AssignBOMCompType();

            if ToContratoPlanningLine.Type <> ToContratoPlanningLine.Type::Text then begin
                FromBOMComp.TestField("No.");
                ValidateContratoPlanningLineData(ContratoPlanningLine);
            end;
            AddDescriptionFromTranslationIfExist();
            ToContratoPlanningLine."BOM Item No." := BOMItemNo;
            ToContratoPlanningLine.Insert();

            ToContratoPlanningLine.Validate("Qty. to Assemble");

            if (ToContratoPlanningLine.Type = ToContratoPlanningLine.Type::Item) and (ToContratoPlanningLine.Reserve = ToContratoPlanningLine.Reserve::Always) then
                ToContratoPlanningLine.AutoReserve();

            if PreviousContratoPlanningLine."Document No." <> '' then
                AddExtText();

            PreviousContratoPlanningLine := ToContratoPlanningLine;
        until FromBOMComp.Next() = 0;

        AddExtText();
    end;

    local procedure ValidateContratoPlanningLineData(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ToContratoPlanningLine.Validate("Planning Date", ContratoPlanningLine."Planning Date");
        ToContratoPlanningLine.Validate("Document No.", ContratoPlanningLine."Document No.");
        ToContratoPlanningLine.Validate("No.", FromBOMComp."No.");
        ToContratoPlanningLine.Validate("Location Code", ContratoPlanningLine."Location Code");
        if FromBOMComp."Variant Code" <> '' then
            ToContratoPlanningLine.Validate("Variant Code", FromBOMComp."Variant Code");
        ValidateQtyAndUoMForDifferentTypes(ContratoPlanningLine);
    end;

    local procedure SetFiltersOnContratoPlanningLine(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ToContratoPlanningLine.Reset();
        ToContratoPlanningLine.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
        ToContratoPlanningLine.SetRange("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
    end;

    local procedure AddExtText()
    begin
        // if TransferExtendedText.JobCheckIfAnyExtText(ToContratoPlanningLine, false) then
        //     TransferExtendedText.InsertJobExtText(ToContratoPlanningLine);
    end;

    local procedure AssignBOMCompType()
    begin
        case FromBOMComp.Type of
            FromBOMComp.Type::" ":
                ToContratoPlanningLine.Type := ToContratoPlanningLine.Type::Text;
            FromBOMComp.Type::Item:
                ToContratoPlanningLine.Type := ToContratoPlanningLine.Type::Item;
            FromBOMComp.Type::Resource:
                ToContratoPlanningLine.Type := ToContratoPlanningLine.Type::Resource;
        end;
    end;

    local procedure AssingContratoPlannigLineDataFromBOMComp()
    begin
        ToContratoPlanningLine."Line No." := 0;
        ToContratoPlanningLine."No." := FromBOMComp."No.";
        ToContratoPlanningLine."Variant Code" := FromBOMComp."Variant Code";
        ToContratoPlanningLine."Unit of Measure Code" := FromBOMComp."Unit of Measure Code";
        ToContratoPlanningLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, FromBOMComp."Unit of Measure Code");
    end;

    local procedure CheckContratoPlanningLine(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ContratoPlanningLine.TestField(Type, ContratoPlanningLine.Type::Item);
        ContratoPlanningLine.CalcFields("Reserved Qty. (Base)");
        ContratoPlanningLine.TestField("Reserved Qty. (Base)", 0);
    end;

    local procedure InitParentItemLine(var FromContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ToContratoPlanningLine := FromContratoPlanningLine;
        ToContratoPlanningLine.Init();
        ToContratoPlanningLine.Type := ToContratoPlanningLine.Type::Text;
        ToContratoPlanningLine.Description := FromContratoPlanningLine.Description;
        ToContratoPlanningLine."Description 2" := FromContratoPlanningLine."Description 2";
        ToContratoPlanningLine."BOM Item No." := BOMItemNo;
        ToContratoPlanningLine.Modify();
    end;

    local procedure ValidateQtyAndUoMForDifferentTypes(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        case ToContratoPlanningLine.Type of
            ToContratoPlanningLine.Type::Item:
                begin
                    Item.Get(FromBOMComp."No.");
                    ToContratoPlanningLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                    ToContratoPlanningLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, ToContratoPlanningLine."Unit of Measure Code");
                    ToContratoPlanningLine.Validate(Quantity, Round(ContratoPlanningLine."Quantity (Base)" * FromBOMComp."Quantity per", UOMMgt.QtyRndPrecision()));
                end;
            ToContratoPlanningLine.Type::Resource:
                begin
                    Resource.Get(FromBOMComp."No.");
                    ToContratoPlanningLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                    ToContratoPlanningLine."Qty. per Unit of Measure" := UOMMgt.GetResQtyPerUnitOfMeasure(Resource, ToContratoPlanningLine."Unit of Measure Code");
                    ToContratoPlanningLine.Validate(Quantity, Round(ContratoPlanningLine."Quantity (Base)" * FromBOMComp."Quantity per", UOMMgt.QtyRndPrecision()));
                end;
            else
                ToContratoPlanningLine.Validate(Quantity, ContratoPlanningLine."Quantity (Base)" * FromBOMComp."Quantity per");
        end;
    end;

    local procedure AddDescriptionFromTranslationIfExist()
    begin
        if Contrato."Language Code" = '' then
            ToContratoPlanningLine.Description := FromBOMComp.Description
        else
            if not ItemTranslation.Get(FromBOMComp."No.", FromBOMComp."Variant Code", Contrato."Language Code") then
                ToContratoPlanningLine.Description := FromBOMComp.Description;
    end;

    local procedure GenerateLineSpacing(InsertLinesBetween: Boolean)
    begin
        if InsertLinesBetween then
            LineSpacing := (ToContratoPlanningLine."Line No." - NextLineNo) div (1 + NoOfBOMComp)
        else
            LineSpacing := 10000;
        if LineSpacing = 0 then
            Error(NotEnoughSpaceMsg);
    end;

    local procedure DeleteReservEntries(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ReservMgt.SetReservSource(ContratoPlanningLine);
        ReservMgt.SetItemTrackingHandling(1);
        ReservMgt.DeleteReservEntries(true, 0);
    end;
}
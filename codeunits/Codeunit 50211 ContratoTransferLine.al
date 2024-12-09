codeunit 50211 "Contrato Transfer Line"
{

    trigger OnRun()
    begin
    end;

    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        LCYCurrency: Record Currency;
        CurrencyRoundingRead: Boolean;
        Text001: Label '%1 %2 does not exist.';
        ContratoPlanningLineNotFoundErr: Label 'Could not find any lines on the %1 page that are related to the %2 where the value in the %3 field is %4, and value in the %5 field is %6.', Comment = '%1=page caption, %2=table caption, %3,%5=field caption, %4,%6=field value';
        DuplicateContratoplanningLinesErr: Label 'We found more than one %1s where the value in the %2 field is %3. The value in the %2 field must be unique.', Comment = '%1=table caption, %2=field caption, %3=field value';

    procedure FromJnlLineToLedgEntry(ContratoJnlLine2: Record "Contrato Journal Line"; var ContratoLedgEntry: Record "Contrato Ledger Entry")
    begin
        ContratoLedgEntry."Contrato No." := ContratoJnlLine2."Contrato No.";
        ContratoLedgEntry."Contrato Task No." := ContratoJnlLine2."Contrato Task No.";
        ContratoLedgEntry."Contrato Posting Group" := ContratoJnlLine2."Posting Group";
        ContratoLedgEntry."Posting Date" := ContratoJnlLine2."Posting Date";
        ContratoLedgEntry."Document Date" := ContratoJnlLine2."Document Date";
        ContratoLedgEntry."Document No." := ContratoJnlLine2."Document No.";
        ContratoLedgEntry."External Document No." := ContratoJnlLine2."External Document No.";
        ContratoLedgEntry.Type := ContratoJnlLine2.Type;
        ContratoLedgEntry."No." := ContratoJnlLine2."No.";
        ContratoLedgEntry.Description := ContratoJnlLine2.Description;
        ContratoLedgEntry."Resource Group No." := ContratoJnlLine2."Resource Group No.";
        ContratoLedgEntry."Unit of Measure Code" := ContratoJnlLine2."Unit of Measure Code";
        ContratoLedgEntry."Location Code" := ContratoJnlLine2."Location Code";
        ContratoLedgEntry."Global Dimension 1 Code" := ContratoJnlLine2."Shortcut Dimension 1 Code";
        ContratoLedgEntry."Global Dimension 2 Code" := ContratoJnlLine2."Shortcut Dimension 2 Code";
        ContratoLedgEntry."Dimension Set ID" := ContratoJnlLine2."Dimension Set ID";
        ContratoLedgEntry."Work Type Code" := ContratoJnlLine2."Work Type Code";
        ContratoLedgEntry."Source Code" := ContratoJnlLine2."Source Code";
        ContratoLedgEntry."Entry Type" := ContratoJnlLine2."Entry Type";
        ContratoLedgEntry."Gen. Bus. Posting Group" := ContratoJnlLine2."Gen. Bus. Posting Group";
        ContratoLedgEntry."Gen. Prod. Posting Group" := ContratoJnlLine2."Gen. Prod. Posting Group";
        ContratoLedgEntry."Journal Batch Name" := ContratoJnlLine2."Journal Batch Name";
        ContratoLedgEntry."Reason Code" := ContratoJnlLine2."Reason Code";
        ContratoLedgEntry."Variant Code" := ContratoJnlLine2."Variant Code";
        ContratoLedgEntry."Bin Code" := ContratoJnlLine2."Bin Code";
        ContratoLedgEntry."Line Type" := ContratoJnlLine2."Line Type";
        ContratoLedgEntry."Currency Code" := ContratoJnlLine2."Currency Code";
        ContratoLedgEntry."Description 2" := ContratoJnlLine2."Description 2";
        if ContratoJnlLine2."Currency Code" = '' then
            ContratoLedgEntry."Currency Factor" := 1
        else
            ContratoLedgEntry."Currency Factor" := ContratoJnlLine2."Currency Factor";
        ContratoLedgEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(ContratoLedgEntry."User ID"));
        ContratoLedgEntry."Customer Price Group" := ContratoJnlLine2."Customer Price Group";

        ContratoLedgEntry."Transport Method" := ContratoJnlLine2."Transport Method";
        ContratoLedgEntry."Transaction Type" := ContratoJnlLine2."Transaction Type";
        ContratoLedgEntry."Transaction Specification" := ContratoJnlLine2."Transaction Specification";
        ContratoLedgEntry."Entry/Exit Point" := ContratoJnlLine2."Entry/Exit Point";
        ContratoLedgEntry.Area := ContratoJnlLine2.Area;
        ContratoLedgEntry."Country/Region Code" := ContratoJnlLine2."Country/Region Code";
        ContratoLedgEntry."Shpt. Method Code" := ContratoJnlLine2."Shpt. Method Code";

        ContratoLedgEntry."Unit Price (LCY)" := ContratoJnlLine2."Unit Price (LCY)";
        ContratoLedgEntry."Additional-Currency Total Cost" :=
          -ContratoJnlLine2."Source Currency Total Cost";
        ContratoLedgEntry."Add.-Currency Total Price" :=
          -ContratoJnlLine2."Source Currency Total Price";
        ContratoLedgEntry."Add.-Currency Line Amount" :=
          -ContratoJnlLine2."Source Currency Line Amount";

        ContratoLedgEntry."Service Order No." := ContratoJnlLine2."Service Order No.";
        ContratoLedgEntry."Posted Service Shipment No." := ContratoJnlLine2."Posted Service Shipment No.";

        // Amounts
        ContratoLedgEntry."Qty. per Unit of Measure" := ContratoJnlLine2."Qty. per Unit of Measure";

        ContratoLedgEntry."Direct Unit Cost (LCY)" := ContratoJnlLine2."Direct Unit Cost (LCY)";
        ContratoLedgEntry."Unit Cost (LCY)" := ContratoJnlLine2."Unit Cost (LCY)";
        ContratoLedgEntry."Unit Cost" := ContratoJnlLine2."Unit Cost";
        ContratoLedgEntry."Unit Price" := ContratoJnlLine2."Unit Price";

        ContratoLedgEntry."Line Discount %" := ContratoJnlLine2."Line Discount %";

        OnAfterFromJnlLineToLedgEntry(ContratoLedgEntry, ContratoJnlLine2);
    end;

    procedure FromJnlToPlanningLine(ContratoJnlLine: Record "Contrato Journal Line"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        ContratoPlanningLine."Contrato No." := ContratoJnlLine."Contrato No.";
        ContratoPlanningLine."Contrato Task No." := ContratoJnlLine."Contrato Task No.";
        ContratoPlanningLine."Planning Date" := ContratoJnlLine."Posting Date";
        ContratoPlanningLine."Currency Date" := ContratoJnlLine."Posting Date";
        ContratoPlanningLine.Type := ContratoJnlLine.Type;
        ContratoPlanningLine."No." := ContratoJnlLine."No.";
        ContratoPlanningLine."Document No." := ContratoJnlLine."Document No.";
        ContratoPlanningLine.Description := ContratoJnlLine.Description;
        ContratoPlanningLine."Description 2" := ContratoJnlLine."Description 2";
        ContratoPlanningLine."Unit of Measure Code" := ContratoJnlLine."Unit of Measure Code";
        ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine.ConvertFromContratoLineType(ContratoJnlLine."Line Type"));
        ContratoPlanningLine."Currency Code" := ContratoJnlLine."Currency Code";
        ContratoPlanningLine."Currency Factor" := ContratoJnlLine."Currency Factor";
        ContratoPlanningLine."Resource Group No." := ContratoJnlLine."Resource Group No.";
        ContratoPlanningLine."Location Code" := ContratoJnlLine."Location Code";
        ContratoPlanningLine."Work Type Code" := ContratoJnlLine."Work Type Code";
        ContratoPlanningLine."Customer Price Group" := ContratoJnlLine."Customer Price Group";
        ContratoPlanningLine."Country/Region Code" := ContratoJnlLine."Country/Region Code";
        ContratoPlanningLine."Gen. Bus. Posting Group" := ContratoJnlLine."Gen. Bus. Posting Group";
        ContratoPlanningLine."Gen. Prod. Posting Group" := ContratoJnlLine."Gen. Prod. Posting Group";
        ContratoPlanningLine."Document Date" := ContratoJnlLine."Document Date";
        ContratoPlanningLine."Variant Code" := ContratoJnlLine."Variant Code";
        ContratoPlanningLine."Bin Code" := ContratoJnlLine."Bin Code";
        ContratoPlanningLine.CopyTrackingFromContratoJnlLine(ContratoJnlLine);
        ContratoPlanningLine."Service Order No." := ContratoJnlLine."Service Order No.";
        ContratoPlanningLine."Ledger Entry Type" := ContratoJnlLine."Ledger Entry Type";
        ContratoPlanningLine."Ledger Entry No." := ContratoJnlLine."Ledger Entry No.";
        ContratoPlanningLine."System-Created Entry" := true;

        // Amounts
        ContratoPlanningLine.Quantity := ContratoJnlLine.Quantity;
        ContratoPlanningLine."Quantity (Base)" := ContratoJnlLine."Quantity (Base)";
        if ContratoPlanningLine."Usage Link" then begin
            ContratoPlanningLine."Remaining Qty." := ContratoJnlLine.Quantity;
            ContratoPlanningLine."Remaining Qty. (Base)" := ContratoJnlLine."Quantity (Base)";
        end;
        ContratoPlanningLine."Qty. per Unit of Measure" := ContratoJnlLine."Qty. per Unit of Measure";

        ContratoPlanningLine."Direct Unit Cost (LCY)" := ContratoJnlLine."Direct Unit Cost (LCY)";
        ContratoPlanningLine."Unit Cost (LCY)" := ContratoJnlLine."Unit Cost (LCY)";
        ContratoPlanningLine."Unit Cost" := ContratoJnlLine."Unit Cost";

        ContratoPlanningLine."Total Cost (LCY)" := ContratoJnlLine."Total Cost (LCY)";
        ContratoPlanningLine."Total Cost" := ContratoJnlLine."Total Cost";

        ContratoPlanningLine."Unit Price (LCY)" := ContratoJnlLine."Unit Price (LCY)";
        ContratoPlanningLine."Unit Price" := ContratoJnlLine."Unit Price";

        ContratoPlanningLine."Total Price (LCY)" := ContratoJnlLine."Total Price (LCY)";
        ContratoPlanningLine."Total Price" := ContratoJnlLine."Total Price";

        ContratoPlanningLine."Line Amount (LCY)" := ContratoJnlLine."Line Amount (LCY)";
        ContratoPlanningLine."Line Amount" := ContratoJnlLine."Line Amount";

        ContratoPlanningLine."Line Discount %" := ContratoJnlLine."Line Discount %";

        ContratoPlanningLine."Line Discount Amount (LCY)" := ContratoJnlLine."Line Discount Amount (LCY)";
        ContratoPlanningLine."Line Discount Amount" := ContratoJnlLine."Line Discount Amount";

        OnAfterFromJnlToPlanningLine(ContratoPlanningLine, ContratoJnlLine);
    end;

    procedure FromPlanningSalesLineToJnlLine(ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var ContratoJnlLine: Record "Contrato Journal Line"; EntryType: Enum ContratoJournalLineEntryType)
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContratoTask: Record "Contrato Task";
    begin
        OnBeforeFromPlanningSalesLineToJnlLine(ContratoPlanningLine, SalesHeader, SalesLine, ContratoJnlLine, EntryType);

        ContratoJnlLine."Line No." := SalesLine."Line No.";
        ContratoJnlLine."Contrato No." := ContratoPlanningLine."Contrato No.";
        ContratoJnlLine."Contrato Task No." := ContratoPlanningLine."Contrato Task No.";
        ContratoJnlLine.Type := ContratoPlanningLine.Type;
        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        ContratoJnlLine."Posting Date" := SalesHeader."Posting Date";
        ContratoJnlLine."Document Date" := SalesHeader."Document Date";
        ContratoJnlLine."Document No." := SalesLine."Document No.";
        ContratoJnlLine."Entry Type" := EntryType;
        ContratoJnlLine."Posting Group" := SalesLine."Posting Group";
        ContratoJnlLine."Gen. Bus. Posting Group" := SalesLine."Gen. Bus. Posting Group";
        ContratoJnlLine."Gen. Prod. Posting Group" := SalesLine."Gen. Prod. Posting Group";
        ContratoJnlLine.CopyTrackingFromContratoPlanningLine(ContratoPlanningLine);
        ContratoJnlLine."No." := ContratoPlanningLine."No.";
        ContratoJnlLine.Description := SalesLine.Description;
        ContratoJnlLine."Description 2" := SalesLine."Description 2";
        ContratoJnlLine."Unit of Measure Code" := ContratoPlanningLine."Unit of Measure Code";
        ContratoJnlLine.Validate("Qty. per Unit of Measure", SalesLine."Qty. per Unit of Measure");
        ContratoJnlLine."Work Type Code" := ContratoPlanningLine."Work Type Code";
        ContratoJnlLine."Variant Code" := ContratoPlanningLine."Variant Code";
        ContratoJnlLine."Line Type" := ContratoPlanningLine.ConvertToContratoLineType();
        ContratoJnlLine."Currency Code" := ContratoPlanningLine."Currency Code";
        ContratoJnlLine."Currency Factor" := ContratoPlanningLine."Currency Factor";
        ContratoJnlLine."Resource Group No." := ContratoPlanningLine."Resource Group No.";
        ContratoJnlLine."Customer Price Group" := ContratoPlanningLine."Customer Price Group";
        ContratoJnlLine."Location Code" := SalesLine."Location Code";
        ContratoJnlLine."Bin Code" := SalesLine."Bin Code";
        ContratoJnlLine."Service Order No." := ContratoPlanningLine."Service Order No.";
        SourceCodeSetup.Get();
        ContratoJnlLine."Source Code" := SourceCodeSetup.Sales;
        ContratoJnlLine."Reason Code" := SalesHeader."Reason Code";
        ContratoJnlLine."External Document No." := SalesHeader."External Document No.";

        ContratoJnlLine."Transport Method" := SalesLine."Transport Method";
        ContratoJnlLine."Transaction Type" := SalesLine."Transaction Type";
        ContratoJnlLine."Transaction Specification" := SalesLine."Transaction Specification";
        ContratoJnlLine."Entry/Exit Point" := SalesLine."Exit Point";
        ContratoJnlLine.Area := SalesLine.Area;
        ContratoJnlLine."Country/Region Code" := ContratoPlanningLine."Country/Region Code";

        ContratoJnlLine."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
        ContratoJnlLine."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
        ContratoJnlLine."Dimension Set ID" := SalesLine."Dimension Set ID";

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                ContratoJnlLine.Validate(Quantity, SalesLine.Quantity);
            SalesHeader."Document Type"::"Credit Memo":
                ContratoJnlLine.Validate(Quantity, -SalesLine.Quantity);
        end;

        OnFromPlanningSalesLineToJnlLineOnBeforeInitAmounts(ContratoJnlLine, SalesLine, SalesHeader);

        ContratoJnlLine."Direct Unit Cost (LCY)" := ContratoPlanningLine."Direct Unit Cost (LCY)";
        if (ContratoPlanningLine."Currency Code" = '') and (SalesHeader."Currency Factor" <> 0) then begin
            GetCurrencyRounding(SalesHeader."Currency Code");
            ValidateUnitCostAndPrice(
              ContratoJnlLine, SalesLine, SalesLine."Unit Cost (LCY)",
              ContratoPlanningLine."Unit Price");
        end else
            ValidateUnitCostAndPrice(ContratoJnlLine, SalesLine, SalesLine."Unit Cost", ContratoPlanningLine."Unit Price");
        ContratoJnlLine.Validate("Line Discount %", SalesLine."Line Discount %");

        OnAfterFromPlanningSalesLineToJnlLine(ContratoJnlLine, ContratoPlanningLine, SalesHeader, SalesLine, EntryType);
    end;

    procedure FromPlanningLineToJnlLine(ContratoPlanningLine: Record "Contrato Planning Line"; PostingDate: Date; ContratoJournalTemplateName: Code[10]; ContratoJournalBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoTask: Record "Contrato Task";
        ContratoJnlLine2: Record "Contrato Journal Line";
        ContratoJournalTemplate: Record "Contrato Journal Template";
        ContratoJournalBatch: Record "Contrato Journal Batch";
        ContratoSetup: Record "Contratos Setup";
        NoSeries: Codeunit "No. Series";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        IsHandled: Boolean;
    begin
        ContratoPlanningLine.TestField("Qty. to Transfer to Journal");

        if not ContratoJournalTemplate.Get(ContratoJournalTemplateName) then
            Error(Text001, ContratoJournalTemplate.TableCaption(), ContratoJournalTemplateName);
        if not ContratoJournalBatch.Get(ContratoJournalTemplateName, ContratoJournalBatchName) then
            Error(Text001, ContratoJournalBatch.TableCaption(), ContratoJournalBatchName);
        if PostingDate = 0D then
            PostingDate := WorkDate();

        ContratoJnlLine.Init();
        ContratoJnlLine.Validate("Journal Template Name", ContratoJournalTemplate.Name);
        ContratoJnlLine.Validate("Journal Batch Name", ContratoJournalBatch.Name);
        ContratoJnlLine2.SetRange("Journal Template Name", ContratoJournalTemplate.Name);
        ContratoJnlLine2.SetRange("Journal Batch Name", ContratoJournalBatch.Name);
        if ContratoJnlLine2.FindLast() then
            ContratoJnlLine.Validate("Line No.", ContratoJnlLine2."Line No." + 10000)
        else
            ContratoJnlLine.Validate("Line No.", 10000);

        ContratoJnlLine."Contrato No." := ContratoPlanningLine."Contrato No.";
        ContratoJnlLine."Contrato Task No." := ContratoPlanningLine."Contrato Task No.";

        if ContratoPlanningLine."Usage Link" then begin
            ContratoJnlLine."Contrato Planning Line No." := ContratoPlanningLine."Line No.";
            ContratoJnlLine."Line Type" := ContratoPlanningLine.ConvertToContratoLineType();
        end;

        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        ContratoJnlLine."Posting Group" := ContratoTask."Contrato Posting Group";
        ContratoJnlLine."Posting Date" := PostingDate;
        ContratoJnlLine."Document Date" := PostingDate;
        ContratoSetup.Get();
        if ContratoJournalBatch."No. Series" <> '' then
            ContratoJnlLine."Document No." := NoSeries.PeekNextNo(ContratoJournalBatch."No. Series", PostingDate)
        else
            if ContratoSetup."Document No. Is Contrato No." then
                ContratoJnlLine."Document No." := ContratoPlanningLine."Contrato No."
            else
                ContratoJnlLine."Document No." := ContratoPlanningLine."Document No.";

        ContratoJnlLine.Type := ContratoPlanningLine.Type;
        ContratoJnlLine."No." := ContratoPlanningLine."No.";
        ContratoJnlLine."Entry Type" := ContratoJnlLine."Entry Type"::Usage;
        ContratoJnlLine."Gen. Bus. Posting Group" := ContratoPlanningLine."Gen. Bus. Posting Group";
        ContratoJnlLine."Gen. Prod. Posting Group" := ContratoPlanningLine."Gen. Prod. Posting Group";
        ContratoJnlLine.CopyTrackingFromContratoPlanningLine(ContratoPlanningLine);
        ContratoJnlLine.Description := ContratoPlanningLine.Description;
        ContratoJnlLine."Description 2" := ContratoPlanningLine."Description 2";
        ContratoJnlLine.Validate("Unit of Measure Code", ContratoPlanningLine."Unit of Measure Code");
        ContratoJnlLine."Currency Code" := ContratoPlanningLine."Currency Code";
        ContratoJnlLine."Currency Factor" := ContratoPlanningLine."Currency Factor";
        ContratoJnlLine."Resource Group No." := ContratoPlanningLine."Resource Group No.";
        ContratoJnlLine."Location Code" := ContratoPlanningLine."Location Code";
        ContratoJnlLine."Work Type Code" := ContratoPlanningLine."Work Type Code";
        ContratoJnlLine."Customer Price Group" := ContratoPlanningLine."Customer Price Group";
        ContratoJnlLine."Variant Code" := ContratoPlanningLine."Variant Code";
        ContratoJnlLine."Bin Code" := ContratoPlanningLine."Bin Code";
        ContratoJnlLine."Service Order No." := ContratoPlanningLine."Service Order No.";
        ContratoJnlLine."Country/Region Code" := ContratoPlanningLine."Country/Region Code";
        ContratoJnlLine."Source Code" := ContratoJournalTemplate."Source Code";

        IsHandled := false;
        OnFromPlanningLineToJnlLineOnBeforeCopyItemTracking(ContratoJnlLine, ContratoPlanningLine, IsHandled);
        if not IsHandled then
            ItemTrackingMgt.CopyItemTracking(ContratoPlanningLine.RowID1(), ContratoJnlLine.RowID1(), false);

        ContratoJnlLine.Validate(Quantity, ContratoPlanningLine."Qty. to Transfer to Journal");
        ContratoJnlLine.Validate("Qty. per Unit of Measure", ContratoPlanningLine."Qty. per Unit of Measure");
        ContratoJnlLine."Direct Unit Cost (LCY)" := ContratoPlanningLine."Direct Unit Cost (LCY)";
        ContratoJnlLine.Validate("Unit Cost", ContratoPlanningLine."Unit Cost");
        ContratoJnlLine.Validate("Unit Price", ContratoPlanningLine."Unit Price");
        ContratoJnlLine.Validate("Line Discount %", ContratoPlanningLine."Line Discount %");
        ContratoJnlLine."Assemble to Order" := ContratoPlanningLine."Assemble to Order";

        OnAfterFromPlanningLineToJnlLine(ContratoJnlLine, ContratoPlanningLine);

        ContratoJnlLine.UpdateDimensions();
        ContratoJnlLine.Insert(true);
    end;

    // Create 'Contrato Journal Line' from 'Warehouse Activity Line'
    procedure FromWarehouseActivityLineToJnlLine(WarehouseActivityLine: Record "Warehouse Activity Line"; PostingDate: Date; ContratoJournalTemplateName: Code[10]; ContratoJournalBatchName: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        ContratoTask: Record "Contrato Task";
        ContratoJnlLine2: Record "Contrato Journal Line";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoJournalTemplate: Record "Contrato Journal Template";
        ContratoJournalBatch: Record "Contrato Journal Batch";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ContratoPlanningLines: Page "Contrato Planning Lines";
    begin
        WarehouseActivityLine.TestField("Qty. to Handle");

        if ContratoJournalTemplateName <> '' then begin
            if not ContratoJournalTemplate.Get(ContratoJournalTemplateName) then
                Error(Text001, ContratoJournalTemplate.TableCaption(), ContratoJournalTemplateName);
            if not ContratoJournalBatch.Get(ContratoJournalTemplateName, ContratoJournalBatchName) then
                Error(Text001, ContratoJournalBatch.TableCaption(), ContratoJournalBatchName);
        end;
        if PostingDate = 0D then
            PostingDate := WorkDate();

        ContratoPlanningLine.SetLoadFields(
            "Contrato No.", "Contrato Task No.", "Usage Link", "Line No.", "Line Type", Type, "No.", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
            "Serial No.", "Lot No.", Description, "Description 2", "Unit of Measure Code", "Currency Code", "Currency Factor", "Resource Group No.",
            "Location Code", "Work Type Code", "Customer Price Group", "Variant Code", "Bin Code", "Service Order No.", "Country/Region Code",
            "Qty. per Unit of Measure", "Direct Unit Cost (LCY)", "Unit Cost", "Unit Price", "Line Discount %", "Document No.", "Assemble to Order");
        ContratoPlanningLine.SetRange("Contrato No.", WarehouseActivityLine."Source No.");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", WarehouseActivityLine."Source Line No.");

        if ContratoPlanningLine.IsEmpty() then
            Error(ContratoPlanningLineNotFoundErr, ContratoPlanningLines.Caption(), WarehouseActivityLine.TableCaption(), WarehouseActivityLine.FieldCaption("Source No."),
                    WarehouseActivityLine."Source No.", WarehouseActivityLine.FieldCaption("Source Line No."), WarehouseActivityLine."Source Line No.");

        if ContratoPlanningLine.Count() > 1 then
            Error(DuplicateContratoplanningLinesErr, ContratoPlanningLine.TableCaption(), ContratoPlanningLine.FieldCaption("Contrato Contract Entry No."), ContratoPlanningLine."Contrato Contract Entry No.");

        ContratoPlanningLine.FindFirst();

        ContratoJnlLine.Init();
        ContratoJnlLine.Validate("Journal Template Name", ContratoJournalTemplate.Name);
        ContratoJnlLine.Validate("Journal Batch Name", ContratoJournalBatch.Name);

        ContratoJnlLine2.SetLoadFields("Line No.");
        ContratoJnlLine2.SetRange("Journal Template Name", ContratoJournalTemplate.Name);
        ContratoJnlLine2.SetRange("Journal Batch Name", ContratoJournalBatch.Name);
        if ContratoJnlLine2.FindLast() then
            ContratoJnlLine.Validate("Line No.", ContratoJnlLine2."Line No." + 10000)
        else
            ContratoJnlLine.Validate("Line No.", 10000);

        ContratoJnlLine."Contrato No." := ContratoPlanningLine."Contrato No.";
        ContratoJnlLine."Contrato Task No." := ContratoPlanningLine."Contrato Task No.";

        if ContratoPlanningLine."Usage Link" then begin
            ContratoJnlLine."Contrato Planning Line No." := ContratoPlanningLine."Line No.";
            ContratoJnlLine."Line Type" := ContratoPlanningLine.ConvertToContratoLineType();
        end;

        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        ContratoJnlLine."Posting Group" := ContratoTask."Contrato Posting Group";
        ContratoJnlLine."Posting Date" := PostingDate;
        ContratoJnlLine."Document Date" := PostingDate;

        ContratoJnlLine."Document No." := ContratoPlanningLine."Contrato No.";
        if ContratoPlanningLine."Document No." <> '' then
            ContratoJnlLine."Document No." := ContratoPlanningLine."Document No.";

        ContratoJnlLine.Type := ContratoPlanningLine.Type;
        ContratoJnlLine."No." := ContratoPlanningLine."No.";
        ContratoJnlLine."Entry Type" := ContratoJnlLine."Entry Type"::Usage;
        ContratoJnlLine."Gen. Bus. Posting Group" := ContratoPlanningLine."Gen. Bus. Posting Group";
        ContratoJnlLine."Gen. Prod. Posting Group" := ContratoPlanningLine."Gen. Prod. Posting Group";
        ContratoJnlLine.CopyTrackingFromContratoPlanningLine(ContratoPlanningLine);
        ContratoJnlLine.Description := WarehouseActivityLine.Description;
        ContratoJnlLine."Description 2" := WarehouseActivityLine."Description 2";
        ContratoJnlLine.Validate("Unit of Measure Code", WarehouseActivityLine."Unit of Measure Code");
        ContratoJnlLine."Currency Code" := ContratoPlanningLine."Currency Code";
        ContratoJnlLine."Currency Factor" := ContratoPlanningLine."Currency Factor";
        ContratoJnlLine."Resource Group No." := ContratoPlanningLine."Resource Group No.";
        ContratoJnlLine."Location Code" := WarehouseActivityLine."Location Code";
        ContratoJnlLine."Work Type Code" := ContratoPlanningLine."Work Type Code";
        ContratoJnlLine."Customer Price Group" := ContratoPlanningLine."Customer Price Group";
        ContratoJnlLine."Variant Code" := WarehouseActivityLine."Variant Code";
        ContratoJnlLine."Bin Code" := WarehouseActivityLine."Bin Code";
        ContratoJnlLine."Service Order No." := ContratoPlanningLine."Service Order No.";
        ContratoJnlLine."Country/Region Code" := ContratoPlanningLine."Country/Region Code";
        ContratoJnlLine."Source Code" := ContratoJournalTemplate."Source Code";
        ContratoJnlLine."Serial No." := WarehouseActivityLine."Serial No.";
        ContratoJnlLine."Lot No." := WarehouseActivityLine."Lot No.";
        ContratoJnlLine."Package No." := WarehouseActivityLine."Package No.";
        ContratoJnlLine."Assemble to Order" := ContratoPlanningLine."Assemble to Order";

        ContratoJnlLine.Validate(Quantity, WarehouseActivityLine."Qty. to Handle");
        ContratoJnlLine.Validate("Qty. per Unit of Measure", WarehouseActivityLine."Qty. per Unit of Measure");
        ContratoJnlLine."Direct Unit Cost (LCY)" := ContratoPlanningLine."Direct Unit Cost (LCY)";
        ContratoJnlLine.Validate("Unit Cost", ContratoPlanningLine."Unit Cost");
        ContratoJnlLine.Validate("Unit Price", ContratoPlanningLine."Unit Price");
        ContratoJnlLine.Validate("Line Discount %", ContratoPlanningLine."Line Discount %");

        ContratoJnlLine.UpdateDimensions();
        ItemTrackingMgt.CopyItemTracking(ContratoPlanningLine.RowID1(), ContratoJnlLine.RowID1(), false);

        OnFromWarehouseActivityLineToJnlLineOnBeforeContratoJnlLineInsert(ContratoJnlLine, ContratoPlanningLine, WarehouseActivityLine);
        ContratoJnlLine.Insert(true);
        OnFromWarehouseActivityLineToJnlLineOnAfterContratoJnlLineInsert(ContratoJnlLine, ContratoPlanningLine, WarehouseActivityLine);
    end;

    procedure FromGenJnlLineToJnlLine(GenJnlLine: Record "Gen. Journal Line"; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
    begin
        OnBeforeFromGenJnlLineToJnlLine(ContratoJnlLine, GenJnlLine);

        ContratoJnlLine."Contrato No." := GenJnlLine."Job No.";
        ContratoJnlLine."Contrato Task No." := GenJnlLine."Job Task No.";
        ContratoTask.Get(GenJnlLine."Job No.", GenJnlLine."Job Task No.");

        ContratoJnlLine."Posting Date" := GenJnlLine."Posting Date";
        ContratoJnlLine."Document Date" := GenJnlLine."Document Date";
        ContratoJnlLine."Document No." := GenJnlLine."Document No.";

        ContratoJnlLine."Currency Code" := GenJnlLine."Job Currency Code";
        ContratoJnlLine."Currency Factor" := GenJnlLine."Job Currency Factor";
        ContratoJnlLine."Entry Type" := ContratoJnlLine."Entry Type"::Usage;
        ContratoJnlLine."Line Type" := GenJnlLine."Job Line Type";
        ContratoJnlLine.Type := ContratoJnlLine.Type::"G/L Account";
        ContratoJnlLine."No." := GenJnlLine."Account No.";
        ContratoJnlLine.Description := GenJnlLine.Description;
        ContratoJnlLine."Unit of Measure Code" := GenJnlLine."Job Unit Of Measure Code";
        ContratoJnlLine."Gen. Bus. Posting Group" := GenJnlLine."Gen. Bus. Posting Group";
        ContratoJnlLine."Gen. Prod. Posting Group" := GenJnlLine."Gen. Prod. Posting Group";
        ContratoJnlLine."Source Code" := GenJnlLine."Source Code";
        ContratoJnlLine."Reason Code" := GenJnlLine."Reason Code";
        Contrato.Get(ContratoJnlLine."Contrato No.");
        ContratoJnlLine."Customer Price Group" := Contrato."Customer Price Group";
        ContratoJnlLine."External Document No." := GenJnlLine."External Document No.";
        ContratoJnlLine."Journal Batch Name" := GenJnlLine."Journal Batch Name";
        ContratoJnlLine."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
        ContratoJnlLine."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
        ContratoJnlLine."Dimension Set ID" := GenJnlLine."Dimension Set ID";

        ContratoJnlLine.Quantity := GenJnlLine."Job Quantity";
        ContratoJnlLine."Quantity (Base)" := GenJnlLine."Job Quantity";
        ContratoJnlLine."Qty. per Unit of Measure" := 1; // MP ??
        ContratoJnlLine."Contrato Planning Line No." := GenJnlLine."Job Planning Line No.";
        ContratoJnlLine."Remaining Qty." := GenJnlLine."Job Remaining Qty.";
        ContratoJnlLine."Remaining Qty. (Base)" := GenJnlLine."Job Remaining Qty.";

        ContratoJnlLine."Direct Unit Cost (LCY)" := GenJnlLine."Job Unit Cost (LCY)";
        ContratoJnlLine."Unit Cost (LCY)" := GenJnlLine."Job Unit Cost (LCY)";
        ContratoJnlLine."Unit Cost" := GenJnlLine."Job Unit Cost";

        ContratoJnlLine."Total Cost (LCY)" := GenJnlLine."Job Total Cost (LCY)";
        ContratoJnlLine."Total Cost" := GenJnlLine."Job Total Cost";

        ContratoJnlLine."Unit Price (LCY)" := GenJnlLine."Job Unit Price (LCY)";
        ContratoJnlLine."Unit Price" := GenJnlLine."Job Unit Price";

        ContratoJnlLine."Total Price (LCY)" := GenJnlLine."Job Total Price (LCY)";
        ContratoJnlLine."Total Price" := GenJnlLine."Job Total Price";

        ContratoJnlLine."Line Amount (LCY)" := GenJnlLine."Job Line Amount (LCY)";
        ContratoJnlLine."Line Amount" := GenJnlLine."Job Line Amount";

        ContratoJnlLine."Line Discount Amount (LCY)" := GenJnlLine."Job Line Disc. Amount (LCY)";
        ContratoJnlLine."Line Discount Amount" := GenJnlLine."Job Line Discount Amount";

        ContratoJnlLine."Line Discount %" := GenJnlLine."Job Line Discount %";

        OnAfterFromGenJnlLineToJnlLine(ContratoJnlLine, GenJnlLine);
    end;

    procedure FromContratoLedgEntryToPlanningLine(ContratoLedgEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        PriceType: Enum "Price Type";
    begin
        ContratoPlanningLine."Contrato No." := ContratoLedgEntry."Contrato No.";
        ContratoPlanningLine."Contrato Task No." := ContratoLedgEntry."Contrato Task No.";
        ContratoPlanningLine."Planning Date" := ContratoLedgEntry."Posting Date";
        ContratoPlanningLine."Currency Date" := ContratoLedgEntry."Posting Date";
        ContratoPlanningLine."Document Date" := ContratoLedgEntry."Document Date";
        ContratoPlanningLine."Document No." := ContratoLedgEntry."Document No.";
        ContratoPlanningLine.Description := ContratoLedgEntry.Description;
        ContratoPlanningLine.Type := ContratoLedgEntry.Type;
        ContratoPlanningLine."No." := ContratoLedgEntry."No.";
        ContratoPlanningLine."Unit of Measure Code" := ContratoLedgEntry."Unit of Measure Code";
        ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine.ConvertFromContratoLineType(ContratoLedgEntry."Line Type"));
        ContratoPlanningLine."Currency Code" := ContratoLedgEntry."Currency Code";
        if ContratoLedgEntry."Currency Code" = '' then
            ContratoPlanningLine."Currency Factor" := 0
        else
            ContratoPlanningLine."Currency Factor" := ContratoLedgEntry."Currency Factor";
        ContratoPlanningLine."Resource Group No." := ContratoLedgEntry."Resource Group No.";
        ContratoPlanningLine."Location Code" := ContratoLedgEntry."Location Code";
        ContratoPlanningLine."Work Type Code" := ContratoLedgEntry."Work Type Code";
        ContratoPlanningLine."Gen. Bus. Posting Group" := ContratoLedgEntry."Gen. Bus. Posting Group";
        ContratoPlanningLine."Gen. Prod. Posting Group" := ContratoLedgEntry."Gen. Prod. Posting Group";
        ContratoPlanningLine."Variant Code" := ContratoLedgEntry."Variant Code";
        ContratoPlanningLine."Bin Code" := ContratoLedgEntry."Bin Code";
        ContratoPlanningLine."Customer Price Group" := ContratoLedgEntry."Customer Price Group";
        ContratoPlanningLine."Country/Region Code" := ContratoLedgEntry."Country/Region Code";
        ContratoPlanningLine."Description 2" := ContratoLedgEntry."Description 2";
        ContratoPlanningLine.CopyTrackingFromContratoLedgEntry(ContratoLedgEntry);
        ContratoPlanningLine."Service Order No." := ContratoLedgEntry."Service Order No.";
        ContratoPlanningLine."Contrato Ledger Entry No." := ContratoLedgEntry."Entry No.";
        ContratoPlanningLine."Ledger Entry Type" := ContratoLedgEntry."Ledger Entry Type";
        ContratoPlanningLine."Ledger Entry No." := ContratoLedgEntry."Ledger Entry No.";
        ContratoPlanningLine."System-Created Entry" := true;

        // Function call to retrieve cost factor. Prices will be overwritten.
        ContratoPlanningLine.ApplyPrice(PriceType::Sale, ContratoTransferMarkerFieldNo());

        // Amounts
        ContratoPlanningLine.Quantity := ContratoLedgEntry.Quantity;
        ContratoPlanningLine."Quantity (Base)" := ContratoLedgEntry."Quantity (Base)";
        if ContratoPlanningLine."Usage Link" then begin
            ContratoPlanningLine."Remaining Qty." := ContratoLedgEntry.Quantity;
            ContratoPlanningLine."Remaining Qty. (Base)" := ContratoLedgEntry."Quantity (Base)";
        end;
        ContratoPlanningLine."Qty. per Unit of Measure" := ContratoLedgEntry."Qty. per Unit of Measure";

        ContratoPlanningLine."Direct Unit Cost (LCY)" := ContratoLedgEntry."Direct Unit Cost (LCY)";
        ContratoPlanningLine."Unit Cost (LCY)" := ContratoLedgEntry."Unit Cost (LCY)";
        ContratoPlanningLine."Unit Cost" := ContratoLedgEntry."Unit Cost";

        ContratoPlanningLine."Total Cost (LCY)" := ContratoLedgEntry."Total Cost (LCY)";
        ContratoPlanningLine."Total Cost" := ContratoLedgEntry."Total Cost";

        ContratoPlanningLine."Unit Price (LCY)" := ContratoLedgEntry."Unit Price (LCY)";
        ContratoPlanningLine."Unit Price" := ContratoLedgEntry."Unit Price";

        ContratoPlanningLine."Total Price (LCY)" := ContratoLedgEntry."Total Price (LCY)";
        ContratoPlanningLine."Total Price" := ContratoLedgEntry."Total Price";

        ContratoPlanningLine."Line Amount (LCY)" := ContratoLedgEntry."Line Amount (LCY)";
        ContratoPlanningLine."Line Amount" := ContratoLedgEntry."Line Amount";

        ContratoPlanningLine."Line Discount %" := ContratoLedgEntry."Line Discount %";

        ContratoPlanningLine."Line Discount Amount (LCY)" := ContratoLedgEntry."Line Discount Amount (LCY)";
        ContratoPlanningLine."Line Discount Amount" := ContratoLedgEntry."Line Discount Amount";

        OnAfterFromContratoLedgEntryToPlanningLine(ContratoPlanningLine, ContratoLedgEntry);
    end;

    procedure ContratoTransferMarkerFieldNo(): Integer;
    begin
        // returns a negative integer (non existing field number) - a marker of Contrato transfer price calculation
        exit(-Database::"Contrato Ledger Entry")
    end;

    procedure FromPurchaseLineToJnlLine(PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line")
    var
        Item: Record Item;
        ContratoTask: Record "Contrato Task";
        PurchLineCurrency: Record "Currency";
        UOMMgt: Codeunit "Unit of Measure Management";
        NonDeductibleVAT: Codeunit "Non-Deductible VAT";
        Factor: Decimal;
        NonDeductibleVATAmount: Decimal;
        NonDeductibleBaseAmount: Decimal;
        NonDeductibleVATAmtPerUnit: Decimal;
        NondeductibleVATAmtPerUnitLCY: Decimal;
        NDVATAmountRounding: Decimal;
        NDVATBaseRounding: Decimal;
        TaxToBeExpensedLCY: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFromPurchaseLineToJnlLine(PurchHeader, PurchInvHeader, PurchCrMemoHeader, PurchLine, SourceCode, ContratoJnlLine, IsHandled);
        if IsHandled then
            exit;

        PurchLine.Validate("Job Planning Line No.");

        ContratoJnlLine.DontCheckStdCost();
        ContratoJnlLine.Validate("Contrato No.", PurchLine."Job No.");
        ContratoJnlLine.Validate("Contrato Task No.", PurchLine."Job Task No.");
        ContratoTask.Get(PurchLine."Job No.", PurchLine."Job Task No.");
        ContratoJnlLine.Validate("Posting Date", PurchHeader."Posting Date");
        ContratoJournalLineValidateType(ContratoJnlLine, PurchLine);
        OnFromPurchaseLineToJnlLineOnBeforeValidateNo(ContratoJnlLine, PurchLine);
        ContratoJnlLine.Validate("No.", PurchLine."No.");
        ContratoJnlLine.Validate("Variant Code", PurchLine."Variant Code");
        if UpdateBaseQtyForPurchLine(Item, PurchLine) then begin
            ContratoJnlLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            ContratoJnlLine.Validate(
                Quantity,
                UOMMgt.CalcBaseQty(
                PurchLine."No.", PurchLine."Variant Code", PurchLine."Unit of Measure Code", PurchLine."Qty. to Invoice", PurchLine."Qty. per Unit of Measure"));
        end else begin
            ContratoJnlLine.Validate("Unit of Measure Code", PurchLine."Unit of Measure Code");
            ContratoJnlLine."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
            ContratoJnlLine.Validate(Quantity, PurchLine."Qty. to Invoice");
        end;

        if PurchHeader."Document Type" in [PurchHeader."Document Type"::"Return Order",
                                            PurchHeader."Document Type"::"Credit Memo"]
        then begin
            ContratoJnlLine."Document No." := PurchCrMemoHeader."No.";
            ContratoJnlLine."External Document No." := PurchCrMemoHeader."Vendor Cr. Memo No.";
        end else begin
            ContratoJnlLine."Document No." := PurchInvHeader."No.";
            ContratoJnlLine."External Document No." := PurchHeader."Vendor Invoice No.";
        end;

        NonDeductibleVAT.Calculate(NonDeductibleBaseAmount, NonDeductibleVATAmount, NonDeductibleVATAmtPerUnit, NonDeductibleVATAmtPerUnitLCY, NDVATAmountRounding, NDVATBaseRounding, PurchHeader, PurchLine);
        GetCurrencyRounding(ContratoJnlLine."Currency Code");

        ContratoJnlLine."Unit Cost (LCY)" := PurchLine."Unit Cost (LCY)" / PurchLine."Qty. per Unit of Measure";
        ContratoJnlLine."Unit Cost" := PurchLine."Unit Cost" / PurchLine."Qty. per Unit of Measure";

        if NonDeductibleVAT.UseNonDeductibleVATAmountForJobCost() then begin
            ContratoJnlLine."Unit Cost (LCY)" += Abs(NonDeductibleVATAmtPerUnitLCY);
            ContratoJnlLine."Unit Cost" += Abs(NonDeductibleVATAmtPerUnit);
        end;

        OnFromPurchaseLineToJnlLineOnAfterCalcUnitCostLCY(ContratoJnlLine, PurchLine);

        TaxToBeExpensedLCY := 0;
        if PurchLine.Type = PurchLine.Type::Item then begin
            if Item."Inventory Value Zero" then begin
                ContratoJnlLine."Unit Cost (LCY)" := 0;
                ContratoJnlLine."Unit Cost" := 0;
            end else
                if Item."Costing Method" = Item."Costing Method"::Standard then begin
                    ContratoJnlLine."Unit Cost (LCY)" := Item."Standard Cost";
                    ContratoJnlLine."Unit Cost" := Item."Standard Cost";
                    if NonDeductibleVAT.UseNonDeductibleVATAmountForJobCost() then begin
                        ContratoJnlLine."Unit Cost (LCY)" += NonDeductibleVATAmtPerUnitLCY;
                        ContratoJnlLine."Unit Cost" += NonDeductibleVATAmtPerUnit;
                    end;
                end;
        end else begin
            TaxToBeExpensedLCY := PurchLine."Tax To Be Expensed";
            if (ContratoJnlLine.Quantity <> 0) and (TaxToBeExpensedLCY <> 0) then begin
                ContratoJnlLine.Validate("Unit Cost (LCY)", PurchLine."Unit Cost (LCY)" + TaxToBeExpensedLCY / ContratoJnlLine.Quantity);
                ContratoJnlLine."Unit Cost" := PurchLine."Unit Cost" + TaxToBeExpensedLCY * PurchHeader."Currency Factor" / ContratoJnlLine.Quantity;
            end;
        end;

        ContratoJnlLine."Unit Cost (LCY)" := Round(ContratoJnlLine."Unit Cost (LCY)", LCYCurrency."Unit-Amount Rounding Precision");

        if (ContratoJnlLine."Currency Code" = '') and (PurchLine."Currency Code" <> '') then begin
            PurchLineCurrency.Get(PurchLine."Currency Code");
            ContratoJnlLine."Total Cost" :=
                Round(
                    CurrencyExchRate.ExchangeAmtFCYToLCY(
                        PurchHeader."Posting Date",
                        PurchLine."Currency Code",
                        Round(ContratoJnlLine."Unit Cost" * ContratoJnlLine.Quantity, PurchLineCurrency."Amount Rounding Precision"),
                        PurchHeader."Currency Factor"),
                    Currency."Amount Rounding Precision");
            ContratoJnlLine."Total Cost (LCY)" := ContratoJnlLine."Total Cost";
        end;

        case ContratoJnlLine."Currency Code" of
            '':
                ContratoJnlLine."Unit Cost" := ContratoJnlLine."Unit Cost (LCY)";
            PurchLine."Currency Code":
                if TaxToBeExpensedLCY <> 0 then
                    ContratoJnlLine."Unit Cost" :=
                        Round(
                            CurrencyExchRate.ExchangeAmtLCYToFCY(
                                PurchHeader."Posting Date",
                                ContratoJnlLine."Currency Code",
                                ContratoJnlLine."Unit Cost (LCY)",
                                ContratoJnlLine."Currency Factor"),
                            Currency."Unit-Amount Rounding Precision")
                else
                    ContratoJnlLine."Unit Cost" := PurchLine."Unit Cost";
            else
                ContratoJnlLine."Unit Cost" :=
                    Round(
                    CurrencyExchRate.ExchangeAmtLCYToFCY(
                        PurchHeader."Posting Date",
                        ContratoJnlLine."Currency Code",
                        ContratoJnlLine."Unit Cost (LCY)",
                        ContratoJnlLine."Currency Factor"), Currency."Unit-Amount Rounding Precision");
        end;

        if not ((ContratoJnlLine."Currency Code" = '') and (PurchLine."Currency Code" <> '')) then
            ContratoJnlLine."Total Cost" := Round(ContratoJnlLine."Unit Cost" * ContratoJnlLine.Quantity, Currency."Amount Rounding Precision");

        if (PurchLine.Type = PurchLine.Type::Item) and Item."Inventory Value Zero" then
            ContratoJnlLine."Total Cost (LCY)" := 0
        else
            if not ((ContratoJnlLine."Currency Code" = '') and (PurchLine."Currency Code" <> '')) then
                ContratoJnlLine."Total Cost (LCY)" :=
                    Round(ContratoJnlLine."Unit Cost (LCY)" * ContratoJnlLine.Quantity, LCYCurrency."Amount Rounding Precision");

        if PurchLine."Currency Code" = '' then
            ContratoJnlLine."Direct Unit Cost (LCY)" := PurchLine."Direct Unit Cost"
        else
            ContratoJnlLine."Direct Unit Cost (LCY)" :=
                CurrencyExchRate.ExchangeAmtFCYToLCY(
                PurchHeader."Posting Date",
                PurchLine."Currency Code",
                PurchLine."Direct Unit Cost",
                PurchHeader."Currency Factor");

        ContratoJnlLine."Unit Price (LCY)" :=
            Round(PurchLine."Job Unit Price (LCY)" / PurchLine."Qty. per Unit of Measure", LCYCurrency."Unit-Amount Rounding Precision");
        ContratoJnlLine."Unit Price" :=
            Round(PurchLine."Job Unit Price" / PurchLine."Qty. per Unit of Measure", Currency."Unit-Amount Rounding Precision");
        ContratoJnlLine."Line Discount %" := PurchLine."Job Line Discount %";

        if PurchLine.Quantity <> 0 then begin
            GetCurrencyRounding(PurchHeader."Currency Code");

            Factor := PurchLine."Qty. to Invoice" / PurchLine.Quantity;
            ContratoJnlLine."Total Price (LCY)" :=
                Round(PurchLine."Job Total Price (LCY)" * Factor, LCYCurrency."Amount Rounding Precision");
            ContratoJnlLine."Total Price" :=
                Round(PurchLine."Job Total Price" * Factor, Currency."Amount Rounding Precision");
            ContratoJnlLine."Line Amount (LCY)" :=
                Round(PurchLine."Job Line Amount (LCY)" * Factor, LCYCurrency."Amount Rounding Precision");
            ContratoJnlLine."Line Amount" :=
                Round(PurchLine."Job Line Amount" * Factor, Currency."Amount Rounding Precision");
            ContratoJnlLine."Line Discount Amount (LCY)" :=
                Round(PurchLine."Job Line Disc. Amount (LCY)" * Factor, LCYCurrency."Amount Rounding Precision");
            ContratoJnlLine."Line Discount Amount" :=
                Round(PurchLine."Job Line Discount Amount" * Factor, Currency."Amount Rounding Precision");
        end;

        ContratoJnlLine."Contrato Planning Line No." := PurchLine."Job Planning Line No.";
        ContratoJnlLine."Remaining Qty." := PurchLine."Job Remaining Qty.";
        ContratoJnlLine."Remaining Qty. (Base)" := PurchLine."Job Remaining Qty. (Base)";
        ContratoJnlLine."Location Code" := PurchLine."Location Code";
        ContratoJnlLine."Bin Code" := PurchLine."Bin Code";
        ContratoJnlLine."Line Type" := PurchLine."Job Line Type";
        ContratoJnlLine."Entry Type" := ContratoJnlLine."Entry Type"::Usage;
        ContratoJnlLine.Description := PurchLine.Description;
        ContratoJnlLine."Description 2" := PurchLine."Description 2";
        ContratoJnlLine."Gen. Bus. Posting Group" := PurchLine."Gen. Bus. Posting Group";
        ContratoJnlLine."Gen. Prod. Posting Group" := PurchLine."Gen. Prod. Posting Group";
        ContratoJnlLine."Source Code" := SourceCode;
        ContratoJnlLine."Reason Code" := PurchHeader."Reason Code";
        ContratoJnlLine."Document Date" := PurchHeader."Document Date";
        ContratoJnlLine."Shortcut Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
        ContratoJnlLine."Shortcut Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code";
        ContratoJnlLine."Dimension Set ID" := PurchLine."Dimension Set ID";

        OnAfterFromPurchaseLineToJnlLine(ContratoJnlLine, PurchHeader, PurchInvHeader, PurchCrMemoHeader, PurchLine, SourceCode);
    end;

    local procedure ContratoJournalLineValidateType(var ContratoJournalLine: Record "Contrato Journal Line"; PurchaseLine: Record "Purchase Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeContratoJournalLineValidateType(ContratoJournalLine, PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            ContratoJournalLine.Validate(Type, ContratoJournalLine.Type::"G/L Account")
        else
            ContratoJournalLine.Validate(Type, ContratoJournalLine.Type::Item);
    end;

    procedure FromSalesHeaderToPlanningLine(SalesLine: Record "Sales Line"; CurrencyFactor: Decimal)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ContratoPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", SalesLine."Job Contract Entry No.");
        if ContratoPlanningLine.FindFirst() then begin
            // Update Prices
            if ContratoPlanningLine."Currency Code" <> '' then begin
                ContratoPlanningLine."Unit Price (LCY)" := SalesLine."Unit Price" / CurrencyFactor;
                ContratoPlanningLine."Total Price (LCY)" := ContratoPlanningLine."Unit Price (LCY)" * ContratoPlanningLine.Quantity;
                ContratoPlanningLine."Line Amount (LCY)" := ContratoPlanningLine."Total Price (LCY)";
                ContratoPlanningLine."Unit Price" := ContratoPlanningLine."Unit Price (LCY)";
                ContratoPlanningLine."Total Price" := ContratoPlanningLine."Total Price (LCY)";
                ContratoPlanningLine."Line Amount" := ContratoPlanningLine."Total Price (LCY)";
            end else begin
                ContratoPlanningLine."Unit Price (LCY)" := SalesLine."Unit Price" / CurrencyFactor;
                ContratoPlanningLine."Total Price (LCY)" := ContratoPlanningLine."Unit Price (LCY)" * ContratoPlanningLine.Quantity;
                ContratoPlanningLine."Line Amount (LCY)" := ContratoPlanningLine."Total Price (LCY)";
            end;
            OnAfterFromSalesHeaderToPlanningLine(ContratoPlanningLine, SalesLine, CurrencyFactor);
            ContratoPlanningLine.Modify();
        end;
    end;

    procedure GetCurrencyRounding(CurrencyCode: Code[10])
    begin
        if CurrencyRoundingRead then
            exit;
        CurrencyRoundingRead := true;
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
        LCYCurrency.InitRoundingPrecision();
    end;

    local procedure DoUpdateUnitCost(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        if SalesLine.Type = SalesLine.Type::Item then begin
            Item.Get(SalesLine."No.");
            if (Item."Costing Method" = Item."Costing Method"::Standard) and not IsCreatedFromContrato(SalesLine) then
                exit(false); // Do not update Unit Cost in Contrato Journal Line, it is correct.
        end;

        exit(true);
    end;

    local procedure IsCreatedFromContrato(var SalesLine: Record "Sales Line") Result: Boolean
    begin
        Result := (SalesLine."Job No." <> '') and (SalesLine."Job Task No." <> '') and (SalesLine."Job Contract Entry No." <> 0);
        OnAfterIsCreatedFromContrato(SalesLine, Result);
    end;

    procedure ValidateUnitCostAndPrice(var ContratoJournalLine: Record "Contrato Journal Line"; SalesLine: Record "Sales Line"; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        if DoUpdateUnitCost(SalesLine) then begin
            ContratoJournalLine.DontCheckStdCost();
            ContratoJournalLine.Validate("Unit Cost", UnitCost);
        end;
        ContratoJournalLine.Validate("Unit Price", UnitPrice);
    end;

    local procedure UpdateBaseQtyForPurchLine(var Item: Record Item; PurchLine: Record "Purchase Line"): Boolean
    begin
        if PurchLine.Type = PurchLine.Type::Item then begin
            Item.Get(PurchLine."No.");
            Item.TestField("Base Unit of Measure");
            exit(PurchLine."Unit of Measure Code" <> Item."Base Unit of Measure");
        end;
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsCreatedFromContrato(var SalesLine: Record "Sales Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromJnlLineToLedgEntry(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromJnlToPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoJournalLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromPlanningSalesLineToJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; EntryType: Enum ContratoJournalLineEntryType)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromPlanningLineToJnlLine(var ContratoJournalLine: Record "Contrato Journal Line"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromGenJnlLineToJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromContratoLedgEntryToPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromPurchaseLineToJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFromSalesHeaderToPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; SalesLine: Record "Sales Line"; CurrencyFactor: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFromPlanningSalesLineToJnlLine(var ContratoPlanningLine: Record "Contrato Planning Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoJnlLine: Record "Contrato Journal Line"; var EntryType: Enum ContratoJournalLineEntryType)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFromPurchaseLineToJnlLine(PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10]; var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoJournalLineValidateType(var ContratoJournalLine: Record "Contrato Journal Line"; PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromPurchaseLineToJnlLineOnBeforeValidateNo(var ContratoJnlLine: Record "Contrato Journal Line"; var PurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromPurchaseLineToJnlLineOnAfterCalcUnitCostLCY(var ContratoJnlLine: Record "Contrato Journal Line"; var PurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromPlanningLineToJnlLineOnBeforeCopyItemTracking(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromWarehouseActivityLineToJnlLineOnAfterContratoJnlLineInsert(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromWarehouseActivityLineToJnlLineOnBeforeContratoJnlLineInsert(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFromPlanningSalesLineToJnlLineOnBeforeInitAmounts(var ContratoJournalLine: Record "Contrato Journal Line"; var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFromGenJnlLineToJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;
}


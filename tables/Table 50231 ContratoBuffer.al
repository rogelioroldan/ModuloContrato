table 50231 "Contrato Buffer"
{
    Caption = 'Contrato Buffer';
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account No. 1"; Code[20])
        {
            Caption = 'Account No. 1';
            DataClassification = SystemMetadata;
        }
        field(2; "Account No. 2"; Code[20])
        {
            Caption = 'Account No. 2';
            DataClassification = SystemMetadata;
        }
        field(3; "Amount 1"; Decimal)
        {
            Caption = 'Amount 1';
            DataClassification = SystemMetadata;
        }
        field(4; "Amount 2"; Decimal)
        {
            Caption = 'Amount 2';
            DataClassification = SystemMetadata;
        }
        field(5; "Amount 3"; Decimal)
        {
            Caption = 'Amount 3';
            DataClassification = SystemMetadata;
        }
        field(6; "Amount 4"; Decimal)
        {
            Caption = 'Amount 4';
            DataClassification = SystemMetadata;
        }
        field(7; "Amount 5"; Decimal)
        {
            Caption = 'Amount 5';
            DataClassification = SystemMetadata;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(11; "New Total"; Boolean)
        {
            Caption = 'New Total';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Account No. 1", "Account No. 2")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        TempContratoBuffer: array[2] of Record "Contrato Buffer" temporary;

    procedure InsertWorkInProgress(var Contrato: Record Contrato)
    var
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
    begin
        Clear(TempContratoBuffer);
        ContratoWIPGLEntry.SetCurrentKey("Contrato No.");
        ContratoWIPGLEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoWIPGLEntry.SetRange(Reversed, false);
        ContratoWIPGLEntry.SetRange("Contrato Complete", false);

        ContratoWIPGLEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));
        if ContratoWIPGLEntry.Find('-') then
            repeat
                Clear(TempContratoBuffer);
                if ContratoWIPGLEntry."G/L Account No." <> '' then begin
                    TempContratoBuffer[1]."Account No. 1" := ContratoWIPGLEntry."G/L Account No.";
                    TempContratoBuffer[1]."Account No. 2" := ContratoWIPGLEntry."Contrato Posting Group";
                    if (ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Applied Costs") or
                       (ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Recognized Costs")
                    then
                        TempContratoBuffer[1]."Amount 1" := ContratoWIPGLEntry."WIP Entry Amount"
                    else
                        if ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Accrued Costs" then
                            TempContratoBuffer[1]."Amount 2" := ContratoWIPGLEntry."WIP Entry Amount";
                    if (ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Applied Sales") or
                       (ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Recognized Sales")
                    then
                        TempContratoBuffer[1]."Amount 4" := ContratoWIPGLEntry."WIP Entry Amount"
                    else
                        if ContratoWIPGLEntry.Type = ContratoWIPGLEntry.Type::"Accrued Sales" then
                            TempContratoBuffer[1]."Amount 5" := ContratoWIPGLEntry."WIP Entry Amount";
                    TempContratoBuffer[2] := TempContratoBuffer[1];
                    if TempContratoBuffer[2].Find() then begin
                        TempContratoBuffer[2]."Amount 1" :=
                          TempContratoBuffer[2]."Amount 1" + TempContratoBuffer[1]."Amount 1";
                        TempContratoBuffer[2]."Amount 2" :=
                          TempContratoBuffer[2]."Amount 2" + TempContratoBuffer[1]."Amount 2";
                        TempContratoBuffer[2]."Amount 4" :=
                          TempContratoBuffer[2]."Amount 4" + TempContratoBuffer[1]."Amount 4";
                        TempContratoBuffer[2]."Amount 5" :=
                          TempContratoBuffer[2]."Amount 5" + TempContratoBuffer[1]."Amount 5";
                        TempContratoBuffer[2].Modify();
                    end else
                        TempContratoBuffer[1].Insert();
                end;
            until ContratoWIPGLEntry.Next() = 0;
    end;

    procedure InitContratoBuffer()
    begin
        Clear(TempContratoBuffer);
        TempContratoBuffer[1].DeleteAll();
    end;

    procedure GetContratoBuffer(var Contrato: Record Contrato; var ContratoBuffer2: Record "Contrato Buffer")
    var
        GLEntry: Record "G/L Entry";
        OldAcc: Code[20];
    begin
        ContratoBuffer2.DeleteAll();
        GLEntry.SetCurrentKey("G/L Account No.", "Job No.", "Posting Date");
        GLEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));
        OldAcc := '';

        if TempContratoBuffer[1].Find('+') then
            repeat
                if TempContratoBuffer[1]."Account No. 1" <> OldAcc then begin
                    GLEntry.SetRange("G/L Account No.", TempContratoBuffer[1]."Account No. 1");
                    GLEntry.SetFilter("Job No.", Contrato.GetFilter("No."));
                    GLEntry.CalcSums(Amount);
                    TempContratoBuffer[1]."Amount 3" := GLEntry.Amount;
                    if TempContratoBuffer[1]."Amount 3" <> 0 then
                        TempContratoBuffer[1]."New Total" := true;
                    OldAcc := TempContratoBuffer[1]."Account No. 1";
                end;
                ContratoBuffer2 := TempContratoBuffer[1];
                ContratoBuffer2.Insert();
            until TempContratoBuffer[1].Next(-1) = 0;
        TempContratoBuffer[1].DeleteAll();
    end;

    procedure ReportContratoItem(var Contrato: Record Contrato; var item2: Record Item; var ContratoBuffer2: Record "Contrato Buffer")
    var
        Item: Record Item;
        Item3: Record Item;
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        InFilter: Boolean;
        Itemfilter: Boolean;
    begin
        Clear(ContratoBuffer2);
        Clear(TempContratoBuffer);
        ContratoBuffer2.DeleteAll();
        TempContratoBuffer[1].DeleteAll();
        if Contrato."No." = '' then
            exit;
        Item.Copy(item2);
        Itemfilter := Item.GetFilters <> '';
        Item.SetCurrentKey("No.");

        ContratoLedgEntry.SetCurrentKey("Contrato No.", "Posting Date");
        ContratoLedgEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoLedgEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));
        if ContratoLedgEntry.Find('-') then
            repeat
                if (ContratoLedgEntry."Entry Type" = ContratoLedgEntry."Entry Type"::Usage) and
                   (ContratoLedgEntry.Type = ContratoLedgEntry.Type::Item) and
                   (ContratoLedgEntry."No." <> '')
                then begin
                    InFilter := true;
                    if Itemfilter then begin
                        Item.Init();
                        Item."No." := ContratoLedgEntry."No.";
                        InFilter := Item.Find();
                    end;
                    if InFilter then begin
                        Item3.Init();
                        if Item3.Get(ContratoLedgEntry."No.") then;
                        Clear(TempContratoBuffer[1]);
                        TempContratoBuffer[1]."Account No. 1" := ContratoLedgEntry."No.";
                        TempContratoBuffer[1]."Account No. 2" := ContratoLedgEntry."Unit of Measure Code";
                        TempContratoBuffer[1].Description := Item3.Description;
                        TempContratoBuffer[1]."Amount 1" := ContratoLedgEntry.Quantity;
                        TempContratoBuffer[1]."Amount 2" := ContratoLedgEntry."Total Cost (LCY)";
                        TempContratoBuffer[1]."Amount 3" := ContratoLedgEntry."Line Amount (LCY)";
                        TempContratoBuffer[2] := TempContratoBuffer[1];
                        OnReportContratoItemOnBeforeUpsertContratoBuffer(TempContratoBuffer, ContratoLedgEntry, Item3);
                        if TempContratoBuffer[2].Find() then begin
                            TempContratoBuffer[2]."Amount 1" :=
                              TempContratoBuffer[2]."Amount 1" + TempContratoBuffer[1]."Amount 1";
                            TempContratoBuffer[2]."Amount 2" :=
                              TempContratoBuffer[2]."Amount 2" + TempContratoBuffer[1]."Amount 2";
                            TempContratoBuffer[2]."Amount 3" :=
                              TempContratoBuffer[2]."Amount 3" + TempContratoBuffer[1]."Amount 3";
                            OnReportContratoItemOnBeforeModifyContratoBuffer(TempContratoBuffer, ContratoLedgEntry);
                            TempContratoBuffer[2].Modify();
                        end else
                            TempContratoBuffer[1].Insert();
                    end;
                end;
            until ContratoLedgEntry.Next() = 0;

        if TempContratoBuffer[1].Find('-') then
            repeat
                ContratoBuffer2 := TempContratoBuffer[1];
                ContratoBuffer2.Insert();
            until TempContratoBuffer[1].Next() = 0;
        TempContratoBuffer[1].DeleteAll();
    end;

    procedure ReportItemContrato(var Item: Record Item; var Contrato2: Record Contrato; var ContratoBuffer2: Record "Contrato Buffer")
    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        Contrato: Record Contrato;
        Contrato3: Record Contrato;
        InFilter: Boolean;
        ContratoFilter: Boolean;
    begin
        Clear(ContratoBuffer2);
        Clear(TempContratoBuffer);
        ContratoBuffer2.DeleteAll();
        TempContratoBuffer[1].DeleteAll();
        if Item."No." = '' then
            exit;
        Contrato.Copy(Contrato2);
        ContratoFilter := Contrato.GetFilters <> '';
        Contrato.SetCurrentKey("No.");

        ContratoLedgEntry.SetCurrentKey("Entry Type", Type, "No.", "Posting Date");
        ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Usage);
        ContratoLedgEntry.SetRange(Type, ContratoLedgEntry.Type::Item);
        ContratoLedgEntry.SetRange("No.", Item."No.");
        ContratoLedgEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));
        if ContratoLedgEntry.Find('-') then
            repeat
                InFilter := true;
                if ContratoFilter then begin
                    Contrato.Init();
                    Contrato."No." := ContratoLedgEntry."Contrato No.";
                    InFilter := Contrato.Find();
                end;
                if InFilter then begin
                    Contrato3.Init();
                    if Contrato3.Get(ContratoLedgEntry."Contrato No.") then;
                    Clear(TempContratoBuffer[1]);
                    TempContratoBuffer[1]."Account No. 1" := ContratoLedgEntry."Contrato No.";
                    TempContratoBuffer[1]."Account No. 2" := ContratoLedgEntry."Unit of Measure Code";
                    TempContratoBuffer[1].Description := Contrato3.Description;
                    TempContratoBuffer[1]."Amount 1" := ContratoLedgEntry.Quantity;
                    TempContratoBuffer[1]."Amount 2" := ContratoLedgEntry."Total Cost (LCY)";
                    TempContratoBuffer[1]."Amount 3" := ContratoLedgEntry."Line Amount (LCY)";
                    TempContratoBuffer[2] := TempContratoBuffer[1];
                    if TempContratoBuffer[2].Find() then begin
                        TempContratoBuffer[2]."Amount 1" :=
                          TempContratoBuffer[2]."Amount 1" + TempContratoBuffer[1]."Amount 1";
                        TempContratoBuffer[2]."Amount 2" :=
                          TempContratoBuffer[2]."Amount 2" + TempContratoBuffer[1]."Amount 2";
                        TempContratoBuffer[2]."Amount 3" :=
                          TempContratoBuffer[2]."Amount 3" + TempContratoBuffer[1]."Amount 3";
                        TempContratoBuffer[2].Modify();
                    end else
                        TempContratoBuffer[1].Insert();
                end;
            until ContratoLedgEntry.Next() = 0;

        if TempContratoBuffer[1].Find('-') then
            repeat
                ContratoBuffer2 := TempContratoBuffer[1];
                ContratoBuffer2.Insert();
            until TempContratoBuffer[1].Next() = 0;
        TempContratoBuffer[1].DeleteAll();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReportContratoItemOnBeforeUpsertContratoBuffer(var TempContratoBuffer: array[2] of Record "Contrato Buffer" temporary; ContratoLedgerEntry: Record "Contrato Ledger Entry"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReportContratoItemOnBeforeModifyContratoBuffer(var TempContratoBuffer: array[2] of Record "Contrato Buffer" temporary; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;
}


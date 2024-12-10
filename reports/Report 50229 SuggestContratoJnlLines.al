report 50229 "Suggest Contrato Jnl. Lines"
{
    Caption = 'Suggest Contrato Jnl. Lines';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which the report or batch Contrato processes information.';
                    }
                    field(EndingDate; EndingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the date to which the report or batch Contrato processes information.';
                    }
                    field(ResourceNoFilter; ResourceNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Resource No. Filter';
                        TableRelation = Resource;
                        ToolTip = 'Specifies the resource number that the batch Contrato will suggest Contrato lines for.';
                    }
                    field(ContratoNoFilter; ContratoNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Contrato No. Filter';
                        TableRelation = Contrato;
                        ToolTip = 'Specifies a filter for the Contrato numbers that will be included in the report.';
                    }
                    field(ContratoTaskNoFilter; ContratoTaskNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Contrato Task No. Filter';
                        ToolTip = 'Specifies a filter for the Contrato task numbers that will be included in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ContratoTask: Record "Contrato Task";
                        begin
                            ContratoTask.FilterGroup(2);
                            if ContratoNoFilter <> '' then
                                ContratoTask.SetFilter("Contrato No.", ContratoNoFilter);
                            ContratoTask.FilterGroup(0);
                            if PAGE.RunModal(PAGE::"Contrato Task List", ContratoTask) = ACTION::LookupOK then
                                ContratoTask.TestField("Contrato Task Type", ContratoTask."Contrato Task Type"::Posting);
                            ContratoTaskNoFilter := ContratoTask."Contrato Task No.";
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        ContratosSetup: Record "Contratos Setup";
        NoSeries: Codeunit "No. Series";
        TimeSheetMgt: Codeunit "Time Sheet Management";
        NextDocNo: Code[20];
        LineNo: Integer;
        QtyToPost: Decimal;
    begin
        DateFilter := TimeSheetMgt.GetDateFilter(StartingDate, EndingDate);
        FillTimeSheetLineBuffer();

        if TempTimeSheetLine.FindSet() then begin
            ContratoJnlLine.LockTable();
            ContratoJnlTemplate.Get(ContratoJnlLine."Journal Template Name");
            ContratoJnlBatch.Get(ContratoJnlLine."Journal Template Name", ContratoJnlLine."Journal Batch Name");
            ContratosSetup.SetLoadFields("Document No. Is Contrato No.");
            ContratosSetup.Get();
            if not ContratosSetup."Document No. Is Contrato No." then
                if ContratoJnlBatch."No. Series" = '' then
                    NextDocNo := ''
                else
                    NextDocNo := NoSeries.PeekNextNo(ContratoJnlBatch."No. Series", TempTimeSheetLine."Time Sheet Starting Date");

            ContratoJnlLine.SetRange("Journal Template Name", ContratoJnlLine."Journal Template Name");
            ContratoJnlLine.SetRange("Journal Batch Name", ContratoJnlLine."Journal Batch Name");
            if ContratoJnlLine.FindLast() then;
            LineNo := ContratoJnlLine."Line No.";

            repeat
                TimeSheetHeader.Get(TempTimeSheetLine."Time Sheet No.");
                TimeSheetDetail.SetRange("Time Sheet No.", TempTimeSheetLine."Time Sheet No.");
                TimeSheetDetail.SetRange("Time Sheet Line No.", TempTimeSheetLine."Line No.");
                if DateFilter <> '' then
                    TimeSheetDetail.SetFilter(Date, DateFilter);
                TimeSheetDetail.SetFilter(Quantity, '<>0');
                TimeSheetDetail.SetRange(Posted, false);
                if TimeSheetDetail.FindSet() then
                    repeat
                        QtyToPost := TimeSheetDetail.GetMaxQtyToPost();
                        if QtyToPost <> 0 then begin
                            ContratoJnlLine.Init();
                            LineNo := LineNo + 10000;
                            ContratoJnlLine."Line No." := LineNo;
                            ContratoJnlLine."Time Sheet No." := TimeSheetDetail."Time Sheet No.";
                            ContratoJnlLine."Time Sheet Line No." := TimeSheetDetail."Time Sheet Line No.";
                            ContratoJnlLine."Time Sheet Date" := TimeSheetDetail.Date;
                            ContratoJnlLine.Validate("Contrato No.", TimeSheetDetail."Job No.");
                            ContratoJnlLine."Source Code" := ContratoJnlTemplate."Source Code";
                            if TimeSheetDetail."Job Task No." <> '' then
                                ContratoJnlLine.Validate("Contrato Task No.", TimeSheetDetail."Job Task No.");
                            ContratoJnlLine.Validate(Type, ContratoJnlLine.Type::Resource);
                            ContratoJnlLine.Validate("No.", TimeSheetHeader."Resource No.");
                            if TempTimeSheetLine."Work Type Code" <> '' then
                                ContratoJnlLine.Validate("Work Type Code", TempTimeSheetLine."Work Type Code");
                            ContratoJnlLine.Validate("Posting Date", TimeSheetDetail.Date);
                            if not ContratosSetup."Document No. Is Contrato No." then begin
                                ContratoJnlLine."Document No." := NextDocNo;
                                NextDocNo := IncStr(NextDocNo);
                            end;
                            ContratoJnlLine."Posting No. Series" := ContratoJnlBatch."Posting No. Series";
                            ContratoJnlLine.Description := TempTimeSheetLine.Description;
                            ContratoJnlLine.Validate(Quantity, QtyToPost);
                            ContratoJnlLine.Validate(Chargeable, TempTimeSheetLine.Chargeable);
                            ContratoJnlLine."Reason Code" := ContratoJnlBatch."Reason Code";
                            OnAfterTransferTimeSheetDetailToContratoJnlLine(ContratoJnlLine, ContratoJnlTemplate, TempTimeSheetLine, TimeSheetDetail, ContratoJnlBatch, LineNo);
                            ContratoJnlLine.Insert();
                        end;
                    until TimeSheetDetail.Next() = 0;
                OnOnPostReportOnTempTimeSheetLineEndLoop(ContratoJnlLine, NextDocNo, LineNo);
            until TempTimeSheetLine.Next() = 0;
        end;
    end;

    var
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoJnlBatch: Record "Contrato Journal Batch";
        ContratoJnlTemplate: Record "Contrato Journal Template";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        TempTimeSheetLine: Record "Time Sheet Line" temporary;
        TimeSheetDetail: Record "Time Sheet Detail";
        ResourceNoFilter: Code[1024];
        ContratoNoFilter: Code[1024];
        ContratoTaskNoFilter: Code[1024];
        StartingDate: Date;
        EndingDate: Date;
        DateFilter: Text[30];

    procedure SetContratoJnlLine(NewContratoJnlLine: Record "Contrato Journal Line")
    begin
        ContratoJnlLine := NewContratoJnlLine;
    end;

    procedure InitParameters(NewContratoJnlLine: Record "Contrato Journal Line"; NewResourceNoFilter: Code[1024]; NewContratoNoFilter: Code[1024]; NewContratoTaskNoFilter: Code[1024]; NewStartingDate: Date; NewEndingDate: Date)
    begin
        ContratoJnlLine := NewContratoJnlLine;
        ResourceNoFilter := NewResourceNoFilter;
        ContratoNoFilter := NewContratoNoFilter;
        ContratoTaskNoFilter := NewContratoTaskNoFilter;
        StartingDate := NewStartingDate;
        EndingDate := NewEndingDate;
    end;

    local procedure FillTimeSheetLineBuffer()
    var
        SkipLine: Boolean;
    begin
        if ResourceNoFilter <> '' then
            TimeSheetHeader.SetFilter("Resource No.", ResourceNoFilter);
        if DateFilter <> '' then begin
            TimeSheetHeader.SetFilter("Starting Date", DateFilter);
            TimeSheetHeader.SetFilter("Starting Date", '..%1', TimeSheetHeader.GetRangeMax("Starting Date"));
            TimeSheetHeader.SetFilter("Ending Date", DateFilter);
            TimeSheetHeader.SetFilter("Ending Date", '%1..', TimeSheetHeader.GetRangeMin("Ending Date"));
        end;

        if TimeSheetHeader.FindSet() then
            repeat
                TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
                TimeSheetLine.SetRange(Type, TimeSheetLine.Type::Job);
                TimeSheetLine.SetRange(Status, TimeSheetLine.Status::Approved);
                if ContratoNoFilter <> '' then
                    TimeSheetLine.SetFilter("Job No.", ContratoNoFilter);
                if ContratoTaskNoFilter <> '' then
                    TimeSheetLine.SetFilter("Job Task No.", ContratoTaskNoFilter);
                TimeSheetLine.SetRange(Posted, false);
                if TimeSheetLine.FindSet() then
                    repeat
                        TempTimeSheetLine := TimeSheetLine;
                        OnBeforeInsertTempTimeSheetLine(ContratoJnlLine, TimeSheetHeader, TempTimeSheetLine, SkipLine);
                        if not SkipLine then
                            TempTimeSheetLine.Insert();
                    until TimeSheetLine.Next() = 0;
            until TimeSheetHeader.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempTimeSheetLine(ContratoJournalLine: Record "Contrato Journal Line"; TimeSheetHeader: Record "Time Sheet Header"; var TempTimeSheetLine: Record "Time Sheet Line" temporary; var SkipLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferTimeSheetDetailToContratoJnlLine(var ContratoJournalLine: Record "Contrato Journal Line"; ContratoJournalTemplate: Record "Contrato Journal Template"; var TempTimeSheetLine: Record "Time Sheet Line" temporary; TimeSheetDetail: Record "Time Sheet Detail"; ContratoJournalBatch: Record "Contrato Journal Batch"; var LineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnPostReportOnTempTimeSheetLineEndLoop(var ContratoJournalLine: Record "Contrato Journal Line"; var NextDocNo: Code[20]; var LineNo: Integer)
    begin
    end;
}


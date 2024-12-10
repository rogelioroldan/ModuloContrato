report 50205 "Contrato Calculate WIP"
{
    AdditionalSearchTerms = 'calculate work in process,calculate work in progress, Contrato Calculate WIP';
    ApplicationArea = All;
    Caption = 'Contrato Calculate WIP';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Planning Date Filter", "Posting Date Filter";

            trigger OnAfterGetRecord()
            var
                ContratoCalculateWIP: Codeunit "Contrato Calculate WIP";
            begin
                ContratoCalculateWIP.ContratoCalcWIP(Contrato, PostingDate, DocNo);
                CalcFields("WIP Warnings");
                WIPPostedWithWarnings := WIPPostedWithWarnings or "WIP Warnings";
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the document.';
                    }
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of a document that the calculation will apply to.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            NoSeries: Codeunit "No. Series";
#if not CLEAN24
            IsHandled: Boolean;
#endif
            NewNoSeriesCode: Code[20];
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate();

            ContratosSetup.Get();

            ContratosSetup.TestField("Contrato Nos.");
#if not CLEAN24
            NoSeriesMgt.RaiseObsoleteOnBeforeInitSeries(ContratosSetup."Contrato WIP Nos.", '', 0D, DocNo, NewNoSeriesCode, IsHandled);
            if not IsHandled then begin
#endif
                NewNoSeriesCode := ContratosSetup."Contrato WIP Nos.";
                DocNo := NoSeries.GetNextNo(NewNoSeriesCode);
#if not CLEAN24
                NoSeriesMgt.RaiseObsoleteOnAfterInitSeries(NewNoSeriesCode, ContratosSetup."Contrato WIP Nos.", 0D, DocNo);
            end;
#endif
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WIPPosted: Boolean;
        WIPQst: Text;
        InfoMsg: Text;
    begin
        ContratoWIPEntry.SetCurrentKey("Contrato No.");
        ContratoWIPEntry.SetFilter("Contrato No.", Contrato.GetFilter("No."));
        WIPPosted := ContratoWIPEntry.FindFirst();
        Commit();

        if WIPPosted then begin
            if WIPPostedWithWarnings then
                InfoMsg := Text002
            else
                InfoMsg := Text000;
            if DIALOG.Confirm(InfoMsg + PreviewQst) then begin
                ContratoWIPEntry.SetRange("Contrato No.", Contrato."No.");
                PAGE.RunModal(PAGE::"Contrato WIP Entries", ContratoWIPEntry);

                WIPQst := StrSubstNo(RunWIPFunctionsQst, 'Contrato Post WIP to G/L');
                if DIALOG.Confirm(WIPQst) then
                    REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Contrato);
            end;
        end else
            Message(Text001);
    end;

    trigger OnPreReport()
    var
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        IsHandled: Boolean;
#endif
        NewNoSeriesCode: Code[20];
    begin
        ContratosSetup.Get();

        if DocNo = '' then begin
            ContratosSetup.TestField("Contrato Nos.");
#if not CLEAN24
            NoSeriesMgt.RaiseObsoleteOnBeforeInitSeries(ContratosSetup."Contrato WIP Nos.", '', 0D, DocNo, NewNoSeriesCode, IsHandled);
            if not IsHandled then begin
#endif
                NewNoSeriesCode := ContratosSetup."Contrato WIP Nos.";
                DocNo := NoSeries.GetNextNo(NewNoSeriesCode);
#if not CLEAN24
                NoSeriesMgt.RaiseObsoleteOnAfterInitSeries(NewNoSeriesCode, ContratosSetup."Contrato WIP Nos.", 0D, DocNo);
            end;
#endif
        end;

        if PostingDate = 0D then
            PostingDate := WorkDate();

        ContratoCalculateBatches.BatchError(PostingDate, DocNo);
    end;

    var
        Text000: Label 'WIP was successfully calculated.\';
        Text001: Label 'There were no new WIP entries created.';
        Text002: Label 'WIP was calculated with warnings.\';
        PreviewQst: Label 'Do you want to preview the posting accounts?';
        RunWIPFunctionsQst: Label 'You must run the %1 function to post the completion entries for this Contrato. \Do you want to run this function now?', Comment = '%1 = The name of the Contrato Post WIP to G/L report';

    protected var
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratosSetup: Record "Contratos Setup";
        ContratoCalculateBatches: Codeunit "Contrato Calculate Batches";
#if not CLEAN24
        [Obsolete('Please use codeunit No. Series instead.', '24.0')]
        NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
        PostingDate: Date;
        DocNo: Code[20];
        WIPPostedWithWarnings: Boolean;

    procedure InitializeRequest()
    begin
        PostingDate := WorkDate();
    end;
}


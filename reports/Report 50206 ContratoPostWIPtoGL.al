report 50206 "Contrato Post WIP to G/L"
{
    AdditionalSearchTerms = 'posted work in process to general ledger,posted work in progress to general ledger, Contrato Post WIP to G/L';
    ApplicationArea = All;
    Caption = 'Contrato Post WIP to G/L';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                GLSetup.Get();
                if GLSetup."Journal Templ. Name Mandatory" then
                    ContratoCalculateWIP.SetGenJnlBatch(GenJnlBatch);
                ContratoCalculateWIP.CalcGLWIP("No.", JustReverse, DocNo, PostingDate, ReplacePostDate);
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
                    field(ReversalPostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Reversal Posting Date';
                        ToolTip = 'Specifies the posting date for the general ledger entries that are posted by this function.';
                    }
                    field(ReversalDocumentNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Reversal Document No.';
                        ToolTip = 'Specifies a document number for the general ledger entries that are posted by this function.';
                    }
                    field(ReverseOnly; JustReverse)
                    {
                        ApplicationArea = All;
                        Caption = 'Reverse Only';
                        ToolTip = 'Specifies that you want to reverse previously posted WIP, but not to post new WIP to the general ledger. This is useful, for example, when you have calculated and posted WIP for a Contrato with an incorrect date and want to reverse the incorrect postings without posting new WIP entries.';
                    }
                    field(UseReversalDate; ReplacePostDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Reversal Date';
                        ToolTip = 'Specifies if you want to use the reversal date as the posting date for both the reversal of the previous WIP calculation and the posting date for the new WIP calculation. This is useful when you want to calculate and post the historical WIP for a period that is already closed. You can reverse the old postings and post the new calculation in an open period by choosing a reversal date in the open period.';
                    }
                    field(JnlTemplateName; GenJnlLineReq."Journal Template Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                        TableRelation = "Gen. Journal Template";
                        ToolTip = 'Specifies the name of the journal template that is used for the posting.';
                        Visible = IsJournalTemplNameVisible;

                        trigger OnValidate()
                        begin
                            GenJnlLineReq."Journal Batch Name" := '';
                        end;
                    }
                    field(JnlBatchName; GenJnlLineReq."Journal Batch Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';
                        ToolTip = 'Specifies the name of the journal batch that is used for the posting.';
                        Visible = IsJournalTemplNameVisible;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJnlManagement: Codeunit GenJnlManagement;
                        begin
                            GenJnlManagement.SetJnlBatchName(GenJnlLineReq);
                            if GenJnlLineReq."Journal Batch Name" <> '' then
                                GenJnlBatch.Get(GenJnlLineReq."Journal Template Name", GenJnlLineReq."Journal Batch Name");
                        end;

                        trigger OnValidate()
                        begin
                            if GenJnlLineReq."Journal Batch Name" <> '' then begin
                                GenJnlLineReq.TestField("Journal Template Name");
                                GenJnlBatch.Get(GenJnlLineReq."Journal Template Name", GenJnlLineReq."Journal Batch Name");
                            end;
                        end;
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
            NoSeriesManagement: Codeunit NoSeriesManagement;
            IsHandled: Boolean;
#endif
            NewNoSeriesCode: Code[20];
        begin
            GLSetup.Get();
            if GLSetup."Journal Templ. Name Mandatory" then begin
                IsJournalTemplNameVisible := true;
                GLSetup.TestField("Job WIP Jnl. Template Name");
                GLSetup.TestField("Job WIP Jnl. Batch Name");
                GenJnlBatch.Get(GLSetup."Job WIP Jnl. Template Name", GLSetup."Job WIP Jnl. Batch Name");
            end;

            if PostingDate = 0D then
                PostingDate := WorkDate();
            DocNo := '';

            ContratosSetup.Get();

            ContratosSetup.TestField("Contrato Nos.");
#if not CLEAN24
            NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(ContratosSetup."Contrato WIP Nos.", '', 0D, DocNo, NewNoSeriesCode, IsHandled);
            if not IsHandled then begin
#endif
                NewNoSeriesCode := ContratosSetup."Contrato WIP Nos.";
                DocNo := NoSeries.GetNextNo(NewNoSeriesCode);
#if not CLEAN24
                NoSeriesManagement.RaiseObsoleteOnAfterInitSeries(NewNoSeriesCode, ContratosSetup."Contrato WIP Nos.", 0D, DocNo);
            end;
#endif

            ReplacePostDate := false;
            JustReverse := false;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Commit();
        Message(WIPSuccessfullyPostedMsg);
    end;

    trigger OnPreReport()
    var
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
#endif
        NewNoSeriesCode: Code[20];
    begin
        ContratosSetup.Get();

        if DocNo = '' then begin
            ContratosSetup.TestField("Contrato Nos.");
#if not CLEAN24
            NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(ContratosSetup."Contrato WIP Nos.", '', 0D, DocNo, NewNoSeriesCode, IsHandled);
            if not IsHandled then begin
#endif
                NewNoSeriesCode := ContratosSetup."Contrato WIP Nos.";
                DocNo := NoSeries.GetNextNo(NewNoSeriesCode);
#if not CLEAN24
                NoSeriesManagement.RaiseObsoleteOnAfterInitSeries(NewNoSeriesCode, ContratosSetup."Contrato WIP Nos.", 0D, DocNo);
            end;
#endif
        end;

        if PostingDate = 0D then
            PostingDate := WorkDate();

        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GenJnlBatch.TestField("No. Series");
            DocNo := NoSeries.GetNextNo(GenJnlBatch."No. Series", PostingDate);
        end;

        ContratoCalculateBatches.BatchError(PostingDate, DocNo);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ContratosSetup: Record "Contratos Setup";
        GenJnlLineReq: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        ContratoCalculateWIP: Codeunit "Contrato Calculate WIP";
        ContratoCalculateBatches: Codeunit "Contrato Calculate Batches";
        WIPSuccessfullyPostedMsg: Label 'WIP was successfully posted to G/L.';
        IsJournalTemplNameVisible: Boolean;

    protected var
        PostingDate: Date;
        DocNo: Code[20];
        JustReverse: Boolean;
        ReplacePostDate: Boolean;

    procedure InitializeRequest(NewDocNo: Code[20])
    begin
        DocNo := NewDocNo;
        PostingDate := WorkDate();
    end;
}


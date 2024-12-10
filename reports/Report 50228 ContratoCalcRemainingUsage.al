report 50228 "Contrato Calc. Remaining Usage"
{
    Caption = 'Contrato Calc. Remaining Usage';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Contrato Task"; "Contrato Task")
        {
            DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
            RequestFilterFields = "Contrato No.", "Contrato Task No.";
            dataitem("Contrato Planning Line"; "Contrato Planning Line")
            {
                DataItemLink = "Contrato No." = field("Contrato No."), "Contrato Task No." = field("Contrato Task No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Line No.");
                RequestFilterFields = Type, "No.", "Planning Date", "Currency Date", "Location Code", "Variant Code", "Work Type Code";

                trigger OnAfterGetRecord()
                begin
                    if not CheckIfContratoPlngLineMeetsReservedFromStockSetting("Remaining Qty. (Base)", ReservedFromStock)
                    then
                        CurrReport.Skip();

                    if ("Contrato No." <> '') and ("Contrato Task No." <> '') then
                        ContratoCalcBatches.CreateJT("Contrato Planning Line");
                end;
            }
        }
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
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of a document that the calculation will apply to.';
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the document.';
                    }
                    field(TemplateName; TemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Template Name';
                        Editable = false;
                        Lookup = false;
                        TableRelation = "Gen. Journal Template";
                        ToolTip = 'Specifies the template name of the Contrato journal where the remaining usage is inserted as lines.';

                        trigger OnValidate()
                        begin
                            if TemplateName = '' then begin
                                BatchName := '';
                                exit;
                            end;
                            GenJnlTemplate.Get(TemplateName);
                            if GenJnlTemplate.Type <> GenJnlTemplate.Type::Jobs then begin
                                GenJnlTemplate.Type := GenJnlTemplate.Type::Jobs;
                                Error(Text001,
                                  GenJnlTemplate.TableCaption(), GenJnlTemplate.FieldCaption(Type), GenJnlTemplate.Type);
                            end;
                        end;
                    }
                    field(BatchName; BatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch Name';
                        Editable = false;
                        Lookup = false;
                        ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if TemplateName = '' then
                                Error(Text000, ContratoJnlLine.FieldCaption("Journal Template Name"));
                            ContratoJnlLine."Journal Template Name" := TemplateName;
                            ContratoJnlLine.FilterGroup := 2;
                            ContratoJnlLine.SetRange("Journal Template Name", TemplateName);
                            ContratoJnlLine.SetRange("Journal Batch Name", BatchName);
                            ContratoJnlManagement.LookupName(BatchName, ContratoJnlLine);
                            ContratoJnlManagement.CheckName(BatchName, ContratoJnlLine);
                        end;

                        trigger OnValidate()
                        begin
                            ContratoJnlManagement.CheckName(BatchName, ContratoJnlLine);
                        end;
                    }
                    field("Reserved From Stock"; ReservedFromStock)
                    {
                        ApplicationArea = Reservation;
                        Caption = 'Reserved from stock';
                        ToolTip = 'Specifies if you want to include only Contrato planning lines that are fully or partially reserved from current stock.';
                        ValuesAllowed = " ", "Full and Partial", Full;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            TemplateName := TemplateName3;
            BatchName := BatchName3;
            DocNo := DocNo2;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        ContratoCalcBatches.PostDiffBuffer(DocNo, PostingDate, TemplateName, BatchName);
    end;

    trigger OnPreReport()
    begin
        ContratoCalcBatches.BatchError(PostingDate, DocNo);
        ContratoCalcBatches.InitDiffBuffer();
    end;

    var
        GenJnlTemplate: Record "Gen. Journal Template";
        ContratoJnlLine: Record "Contrato Journal Line";
        ContratoCalcBatches: Codeunit "Contrato Calculate Batches";
        ContratoJnlManagement: Codeunit ContratoJnlManagement;
        ReservedFromStock: Enum "Reservation From Stock";
        DocNo: Code[20];
        DocNo2: Code[20];
        PostingDate: Date;
        TemplateName: Code[10];
        BatchName: Code[10];
        TemplateName3: Code[10];
        BatchName3: Code[10];
        Text000: Label 'You must specify %1.';
        Text001: Label '%1 %2 must be %3.';

    procedure SetBatch(TemplateName2: Code[10]; BatchName2: Code[10])
    begin
        TemplateName3 := TemplateName2;
        BatchName3 := BatchName2;
    end;

    procedure SetDocNo(InputDocNo: Code[20])
    begin
        DocNo2 := InputDocNo;
    end;
}


report 50226 "Contrato Split Planning Line"
{
    AdditionalSearchTerms = 'Contrato Split Planning Line';
    ApplicationArea = All;
    Caption = 'Contrato Split Planning Line';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Contrato Task"; "Contrato Task")
        {
            DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
            RequestFilterFields = "Contrato No.", "Contrato Task No.", "Planning Date Filter";

            trigger OnAfterGetRecord()
            begin
                Clear(CalcBatches);
                NoOfLinesSplit += CalcBatches.SplitLines("Contrato Task");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if NoOfLinesSplit <> 0 then
            Message(Text000, NoOfLinesSplit)
        else
            Message(Text001);
    end;

    trigger OnPreReport()
    begin
        NoOfLinesSplit := 0;
    end;

    var
        CalcBatches: Codeunit "Contrato Calculate Batches";
        NoOfLinesSplit: Integer;
        Text000: Label '%1 planning line(s) successfully split.';
        Text001: Label 'There were no planning lines to split.';
}


page 50245 "Res.Gr.AllocatedperContrato"
{
    Caption = 'Res. Gr. Allocated per Contrato';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Resource Gr. Filter"; ResourceGrFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Resource Gr. Filter';
                    Lookup = true;
                    TableRelation = "Resource Group";
                    ToolTip = 'Specifies the resource group that the allocations apply to.';
                }
            }
            group("Matrix Options")
            {
                Caption = 'Matrix Options';
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = All;
                    Caption = 'View by';
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        DateControl();
                        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
                        CurrPage.Update();
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    begin
                        DateControl();
                        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
                        CurrPage.Update();
                    end;
                }
                field(ColumnsSet; ColumnsSet)
                {
                    ApplicationArea = All;
                    Caption = 'Column set';
                    Editable = false;
                    ToolTip = 'Specifies the range of values that are displayed in the matrix window, for example, the total period. To change the contents of the field, choose Next Set or Previous Set.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowMatrix)
            {
                ApplicationArea = All;
                Caption = 'Show Matrix';
                Image = ShowMatrix;
                ToolTip = 'Open the matrix window to see data according to the specified values.';

                trigger OnAction()
                var
                    ContratoPlanningLine: Record "Contrato Planning Line";
                    ResGrpPerContratoFormWithMatrix: Page "ResGrp.Alloc.perContratoMatrix";
                    IsHandled: Boolean;
                begin
                    IsHandled := false;
                    OnActionShowMatrix(ContratoRec, ResourceGrFilter, MatrixColumnCaptions, MatrixRecords, IsHandled);
                    if IsHandled then
                        exit;

                    ContratoPlanningLine.SetRange("Resource Group No.", ResourceGrFilter);
                    ContratoPlanningLine.SetRange(Type, ContratoPlanningLine.Type::Resource);
                    ContratoRec.SetRange("Resource Gr. Filter", ResourceGrFilter);
                    OnActionShowMatrixOnAfterSetContratoFilters(ContratoRec);
                    ResGrpPerContratoFormWithMatrix.Load(ContratoRec, ContratoPlanningLine, MatrixColumnCaptions, MatrixRecords);
                    ResGrpPerContratoFormWithMatrix.RunModal();
                end;
            }
            action("Previous Set")
            {
                ApplicationArea = All;
                Caption = 'Previous Set';
                Image = PreviousSet;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                begin
                    SetMatrixColumns(Enum::"Matrix Page Step Type"::Previous);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = All;
                Caption = 'Next Set';
                Image = NextSet;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                begin
                    SetMatrixColumns(Enum::"Matrix Page Step Type"::Next);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowMatrix_Promoted; ShowMatrix)
                {
                }
                actionref("Previous Set_Promoted"; "Previous Set")
                {
                }
                actionref("Next Set_Promoted"; "Next Set")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
        if Rec.HasFilter then
            ResourceGrFilter := Rec.GetFilter("Resource Gr. Filter");
    end;

    var
        MatrixRecords: array[32] of Record Date;
        ContratoRec: Record Contrato;
        ResRec2: Record Resource;
        FilterTokens: Codeunit "Filter Tokens";
        DateFilter: Text;
        ResourceGrFilter: Text;
        PeriodType: Enum "Analysis Period Type";
        CurrSetLength: Integer;
        PKFirstRecInCurrSet: Text[1024];
        MatrixColumnCaptions: array[32] of Text[100];
        ColumnsSet: Text[1024];

    local procedure DateControl()
    begin
        FilterTokens.MakeDateFilter(DateFilter);
        ResRec2.SetFilter("Date Filter", DateFilter);
        DateFilter := ResRec2.GetFilter("Date Filter");
    end;

    procedure SetMatrixColumns(StepType: Enum "Matrix Page Step Type")
    var
        MatrixMgt: Codeunit "Matrix Management";
    begin
        MatrixMgt.GeneratePeriodMatrixData(
            StepType.AsInteger(), 32, false, PeriodType, DateFilter, PKFirstRecInCurrSet, MatrixColumnCaptions,
            ColumnsSet, CurrSetLength, MatrixRecords);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionShowMatrix(var ContratoRec: Record Contrato; ResourceGrFilter: Text; MatrixColumnCaptions: array[32] of Text; MatrixRecords: array[32] of Record Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionShowMatrixOnAfterSetContratoFilters(var ContratoRec: Record Contrato)
    begin
    end;
}

